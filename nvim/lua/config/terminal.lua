-- Toggleable terminals, sending text to them, and tmux-style window zoom.

local M = {}

M.opts = {
    -- split height as a fraction of the screen
    size = 0.3,
    -- defaults to 'shell'
    shell = nil,
    start_insert = true,
    -- close the window when the shell exits
    close_on_exit = true,
    -- map <Esc><Esc> to leave terminal mode. Off by default: it delays a lone
    -- <Esc> by 'timeoutlen', which is painful inside nested vim/less/fzf.
    -- <C-\><C-n> always works regardless.
    esc_esc = false,
    -- window navigation straight from terminal mode, no <C-\><C-n> first.
    -- these keys stop reaching the shell (C-l clear, C-k kill-line, ...) --
    -- but tmux's vim-tmux-navigator already eats them in every other pane.
    -- set to a table like { "<M-h>", "<M-j>", "<M-k>", "<M-l>" } to use Alt instead.
    terminal_nav = { "<C-h>", "<C-j>", "<C-k>", "<C-l>" },
}

-- terminals[id] = { buf = <bufnr>, job = <chan> }
local terminals = {}
local last_sent = nil

local function win_showing(buf)
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.api.nvim_win_get_buf(win) == buf then return win end
    end
end

local function alive(id)
    local t = terminals[id]
    return t and vim.api.nvim_buf_is_valid(t.buf) and t or nil
end

function M.open(id)
    id = id or 1
    local height = math.max(math.floor(vim.o.lines * M.opts.size), 5)
    local t = alive(id)

    -- already visible: just focus it
    if t then
        local win = win_showing(t.buf)
        if win then
            vim.api.nvim_set_current_win(win)
            if M.opts.start_insert then vim.cmd.startinsert() end
            return t
        end
    end

    vim.cmd(("botright %dsplit"):format(height))
    local win = vim.api.nvim_get_current_win()

    if t then
        vim.api.nvim_win_set_buf(win, t.buf)
    else
        -- listed=false, scratch=false: a terminal needs a real, empty buffer
        local buf = vim.api.nvim_create_buf(false, false)
        vim.api.nvim_win_set_buf(win, buf)
        local job = vim.fn.jobstart(M.opts.shell or vim.o.shell, {
            term = true,
            on_exit = function()
                terminals[id] = nil
                if not M.opts.close_on_exit then return end
                vim.schedule(function()
                    local w = vim.api.nvim_buf_is_valid(buf) and win_showing(buf)
                    if w and #vim.api.nvim_tabpage_list_wins(0) > 1 then
                        pcall(vim.api.nvim_win_close, w, true)
                    end
                    pcall(vim.api.nvim_buf_delete, buf, { force = true })
                end)
            end,
        })
        t = { buf = buf, job = job }
        terminals[id] = t
    end

    vim.wo[win].number = false
    vim.wo[win].relativenumber = false
    vim.wo[win].signcolumn = "no"
    vim.wo[win].foldcolumn = "0"
    if M.opts.start_insert then vim.cmd.startinsert() end
    return t
end

function M.toggle(id)
    id = id or 1
    local t = alive(id)
    if t then
        local win = win_showing(t.buf)
        -- don't leave the tabpage empty
        if win and #vim.api.nvim_tabpage_list_wins(0) > 1 then
            vim.api.nvim_win_close(win, false)
            return
        end
    end
    M.open(id)
end

function M.kill(id)
    id = id or 1
    local t = alive(id)
    if not t then return end
    terminals[id] = nil
    pcall(vim.fn.jobstop, t.job)
    pcall(vim.api.nvim_buf_delete, t.buf, { force = true })
end

---Send `text` to terminal `id`, opening it if needed, without stealing focus.
function M.send(text, id)
    id = id or 1
    if not text or text == "" then return end
    if not text:match("\n$") then text = text .. "\n" end

    local t = alive(id)
    if not t then
        local from = vim.api.nvim_get_current_win()
        t = M.open(id)
        vim.cmd.stopinsert()
        if vim.api.nvim_win_is_valid(from) then vim.api.nvim_set_current_win(from) end
    end

    last_sent = text
    pcall(vim.api.nvim_chan_send, t.job, text)

    -- keep the terminal scrolled to the output we just triggered
    local win = win_showing(t.buf)
    if win then
        pcall(vim.api.nvim_win_set_cursor, win, { vim.api.nvim_buf_line_count(t.buf), 0 })
    end
end

function M.send_line()
    M.send(vim.api.nvim_get_current_line(), vim.v.count1)
end

function M.send_selection()
    local mode = vim.fn.mode()
    local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = mode })
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
    M.send(table.concat(lines, "\n"))
end

function M.resend()
    if last_sent then M.send(last_sent, vim.v.count1) end
end

-- Move to the window in `dir`, crossing into tmux panes at the edge if
-- nvim-tmux-navigation is around, so terminal mode behaves like normal mode.
local function navigate(dir)
    local ok, nav = pcall(require, "nvim-tmux-navigation")
    if ok and nav then
        local fn = ({
            h = nav.NvimTmuxNavigateLeft,
            j = nav.NvimTmuxNavigateDown,
            k = nav.NvimTmuxNavigateUp,
            l = nav.NvimTmuxNavigateRight,
        })[dir]
        if fn then return fn() end
    end
    vim.cmd("wincmd " .. dir)
end

-- Terminals we left *from terminal mode*, so coming back should drop us
-- straight back into insert. Leaving deliberately with <C-\><C-n> clears it,
-- so a terminal you are reading in normal mode stays in normal mode.
local resume_insert = {}

--- tmux-style zoom: maximize the current window, press again to restore.
local zoomed = {}

function M.zoom()
    local tab = vim.api.nvim_get_current_tabpage()
    local saved = zoomed[tab]

    if saved then
        zoomed[tab] = nil
        pcall(vim.cmd, saved.layout)
        if vim.api.nvim_win_is_valid(saved.win) then
            vim.api.nvim_set_current_win(saved.win)
        end
        return
    end

    if #vim.api.nvim_tabpage_list_wins(tab) < 2 then
        vim.notify("Nothing to zoom: only one window", vim.log.levels.INFO)
        return
    end

    zoomed[tab] = { layout = vim.fn.winrestcmd(), win = vim.api.nvim_get_current_win() }
    vim.cmd("wincmd _ | wincmd |")
end

function M.setup(opts)
    M.opts = vim.tbl_extend("force", M.opts, opts or {})

    local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
    end

    map("n", "<leader>tt", function() M.toggle(vim.v.count1) end, "Toggle terminal")
    map("n", "<leader>ts", M.send_line, "Send line to terminal")
    map("x", "<leader>ts", M.send_selection, "Send selection to terminal")
    map("n", "<leader>tr", M.resend, "Resend last text to terminal")
    map("n", "<leader>tk", function() M.kill(vim.v.count1) end, "Kill terminal")
    map({ "n", "x" }, "<leader>z", M.zoom, "Zoom window (tmux-style)")

    if M.opts.esc_esc then
        map("t", "<Esc><Esc>", [[<C-\><C-n>]], "Leave terminal mode")
    end

    -- NOTE: <C-\> is deliberately not mapped here; it would shadow <C-\><C-n>.
    for i, dir in ipairs({ "h", "j", "k", "l" }) do
        local lhs = M.opts.terminal_nav and M.opts.terminal_nav[i]
        if lhs then
            map("t", lhs, function()
                local buf = vim.api.nvim_get_current_buf()
                navigate(dir)
                -- set after navigating: the window switch fires TermLeave,
                -- which would otherwise clear the flag we just set
                resume_insert[buf] = true
            end, "Go to window " .. dir)
        end
    end

    vim.api.nvim_create_user_command("TermSend", function(a)
        M.send(a.args, a.count > 0 and a.count or 1)
    end, { nargs = "+", count = true, desc = "Send text to a terminal" })

    local group = vim.api.nvim_create_augroup("TerminalLook", { clear = true })

    vim.api.nvim_create_autocmd("TermOpen", {
        group = group,
        callback = function(args)
            vim.bo[args.buf].buflisted = false
            vim.opt_local.number = false
            vim.opt_local.relativenumber = false
            vim.opt_local.signcolumn = "no"
        end,
    })

    -- stepping back into a terminal we navigated away from resumes insert
    vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
        group = group,
        callback = function(args)
            if vim.bo[args.buf].buftype == "terminal" and resume_insert[args.buf] then
                vim.cmd.startinsert()
            end
        end,
    })

    -- ...but <C-\><C-n> means "I want normal mode here", so respect that
    vim.api.nvim_create_autocmd("TermLeave", {
        group = group,
        callback = function(args) resume_insert[args.buf] = nil end,
    })

    vim.api.nvim_create_autocmd("BufWipeout", {
        group = group,
        callback = function(args) resume_insert[args.buf] = nil end,
    })

    return M
end

return M
