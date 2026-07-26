-- Persistent list of opened files, most recently opened first, remembering the
-- cursor position we left each file at. Survives restarts by writing to a small
-- json file under stdpath("data").

---@diagnostic disable-next-line: deprecated
local uv = vim.uv or vim.loop

local M = {}

M.opts = {
    path = vim.fn.stdpath("data") .. "/mru.json",
    max = 500,
    -- jump to the remembered position every time a tracked file is opened,
    -- not only when picked through <leader>fo
    restore_on_open = false,
    ignore_filetypes = { "gitcommit", "gitrebase", "help", "qf" },
}

-- { path = <absolute>, lnum = <1-based>, col = <1-based>, ts = <os.time()> }
local entries = {}
local loaded = false
local save_pending = false

local function index_of(list, path)
    for i, e in ipairs(list) do
        if e.path == path then return i end
    end
end

local function read_file(path)
    local fd = uv.fs_open(path, "r", 438)
    if not fd then return end
    local stat = uv.fs_fstat(fd)
    local data = stat and uv.fs_read(fd, stat.size, 0) or nil
    uv.fs_close(fd)
    if not data or #data == 0 then return end
    local ok, decoded = pcall(vim.json.decode, data)
    if ok and type(decoded) == "table" then return decoded end
end

local function sanitize(list)
    local out = {}
    for _, e in ipairs(list or {}) do
        if type(e) == "table" and type(e.path) == "string" and #e.path > 0 then
            out[#out + 1] = {
                path = e.path,
                lnum = tonumber(e.lnum) or 1,
                col = tonumber(e.col) or 1,
                ts = tonumber(e.ts) or 0,
            }
        end
    end
    return out
end

function M.load()
    if loaded then return end
    loaded = true
    entries = sanitize((read_file(M.opts.path) or {}).entries)
end

-- Our own list wins on ordering, but another nvim instance may have visited
-- files we never saw, or left a newer position in a file we both have.
local function merged_with_disk()
    local disk = sanitize((read_file(M.opts.path) or {}).entries)
    local mine, out = {}, {}
    for _, e in ipairs(entries) do
        mine[e.path] = e
        out[#out + 1] = e
    end
    for _, e in ipairs(disk) do
        local ours = mine[e.path]
        if not ours then
            out[#out + 1] = e
        elseif e.ts > ours.ts then
            ours.lnum, ours.col, ours.ts = e.lnum, e.col, e.ts
        end
    end
    while #out > M.opts.max do table.remove(out) end
    return out
end

function M.save()
    save_pending = false
    if not loaded then return end
    local out = merged_with_disk()
    local ok, encoded = pcall(vim.json.encode, { version = 1, entries = out })
    if not ok then return end
    local fd = uv.fs_open(M.opts.path, "w", 420)
    if not fd then return end
    uv.fs_write(fd, encoded, 0)
    uv.fs_close(fd)
    entries = out
end

local function schedule_save()
    if save_pending then return end
    save_pending = true
    vim.defer_fn(function()
        if save_pending then M.save() end
    end, 2000)
end

-- Absolute path of `buf` if it is a real file we want to remember, else nil.
local function trackable(buf)
    if not buf or not vim.api.nvim_buf_is_valid(buf) then return end
    if vim.bo[buf].buftype ~= "" then return end
    if vim.tbl_contains(M.opts.ignore_filetypes, vim.bo[buf].filetype) then return end
    local name = vim.api.nvim_buf_get_name(buf)
    if name == "" or name:match("^%a[%w+.%-]*://") then return end
    local p = vim.fs.normalize(vim.fn.fnamemodify(name, ":p"))
    local stat = uv.fs_stat(p)
    if stat and stat.type == "file" then return p end
end

function M.touch(buf)
    M.load()
    local p = trackable(buf)
    if not p then return end
    local i = index_of(entries, p)
    -- reuse the existing entry so we keep the position we left it at
    local e = i and table.remove(entries, i) or { path = p, lnum = 1, col = 1 }
    e.ts = os.time()
    table.insert(entries, 1, e)
    while #entries > M.opts.max do table.remove(entries) end
    schedule_save()
end

function M.update_pos(buf)
    M.load()
    local p = trackable(buf)
    if not p then return end
    local e = entries[index_of(entries, p) or 0]
    if not e then return end
    local pos
    local win = vim.fn.bufwinid(buf)
    if win ~= -1 then
        pos = vim.api.nvim_win_get_cursor(win)
    else
        -- nvim keeps the last cursor position of a hidden buffer in the '"' mark
        local ok, mark = pcall(vim.api.nvim_buf_get_mark, buf, '"')
        if ok and mark[1] > 0 then pos = mark end
    end
    if not pos then return end
    e.lnum, e.col, e.ts = pos[1], pos[2] + 1, os.time()
    schedule_save()
end

---@return { path: string, lnum: integer, col: integer, ts: integer }[]
function M.list()
    M.load()
    local out = {}
    for _, e in ipairs(entries) do
        if uv.fs_stat(e.path) then out[#out + 1] = e end
    end
    return out
end

local function restore(buf)
    if vim.b[buf].mru_restored then return end
    vim.b[buf].mru_restored = true
    if not M.opts.restore_on_open then return end
    local p = trackable(buf)
    if not p then return end
    local e = entries[index_of(entries, p) or 0]
    local win = vim.fn.bufwinid(buf)
    if not e or win == -1 then return end
    local lnum = math.min(e.lnum, vim.api.nvim_buf_line_count(buf))
    pcall(vim.api.nvim_win_set_cursor, win, { lnum, math.max(e.col - 1, 0) })
end

function M.pick(opts)
    local fzf = require("fzf-lua")
    local make_entry = require("fzf-lua.make_entry")
    local fzf_actions = require("fzf-lua.actions")

    opts = vim.tbl_deep_extend("force", {
        prompt      = "Opened> ",
        previewer   = "builtin",
        _type       = "file",
        file_icons  = true,
        color_icons = true,
        git_icons   = false,
        cwd         = uv.cwd(),
        -- the default file actions minus the toggles (ignore/hidden/follow),
        -- which reload from a shell command we don't have
        actions     = {
            ["enter"]  = fzf_actions.file_edit_or_qf,
            ["ctrl-s"] = fzf_actions.file_split,
            ["ctrl-v"] = fzf_actions.file_vsplit,
            ["ctrl-t"] = fzf_actions.file_tabedit,
            ["alt-q"]  = fzf_actions.file_sel_to_qf,
        },
        -- keep our own ordering instead of letting fzf re-rank equal scores
        fzf_opts    = { ["--tiebreak"] = "index", ["--no-multi"] = true },
    }, opts or {})

    local contents = {}
    for _, e in ipairs(M.list()) do
        -- "path:line:col:" is the grep-style entry fzf-lua knows how to open
        local entry = make_entry.file(("%s:%d:%d:"):format(e.path, e.lnum, e.col), opts)
        if entry then contents[#contents + 1] = entry end
    end

    return fzf.fzf_exec(contents, opts)
end

function M.setup(opts)
    M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
    M.load()

    local group = vim.api.nvim_create_augroup("MruFiles", { clear = true })

    vim.api.nvim_create_autocmd("BufWinEnter", {
        group = group,
        callback = function(args)
            restore(args.buf)
            M.touch(args.buf)
        end,
    })

    vim.api.nvim_create_autocmd({ "BufLeave", "BufWinLeave", "CursorHold" }, {
        group = group,
        callback = function(args) M.update_pos(args.buf) end,
    })

    vim.api.nvim_create_autocmd("VimLeavePre", {
        group = group,
        callback = function()
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do M.update_pos(buf) end
            M.save()
        end,
    })
end

return M
