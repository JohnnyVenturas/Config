-- Fold appearance.
--
-- The fold *method* is set in lua/plugins/tree_sitter.lua (treesitter foldexpr);
-- this file only deals with how a closed fold is drawn.

local M = {}

M.opts = {
    -- keep treesitter syntax colors on the folded line instead of painting the
    -- whole line one flat color
    syntax_highlight = true,

    -- trailing summary, rendered in the dim "FoldCount" group
    suffix = function(count) return ("  󰁂 %d lines"):format(count) end,

    -- subtle bar behind a closed fold; set to "NONE" to keep it transparent
    background = true,

    -- "0" hides the fold gutter, "1" or "auto:1" shows it
    foldcolumn = "0",

    -- tree_sitter.lua sets foldlevel=0, so files open fully folded.
    -- set this to true to open them expanded instead.
    start_open = false,
}

-- Grays pulled from the active catppuccin flavour, with a standalone fallback
-- so this still works if the colorscheme changes.
local function resolve_colors()
    local ok, palette = pcall(function()
        return require("catppuccin.palettes").get_palette()
    end)
    if ok and type(palette) == "table" and palette.overlay0 then
        return {
            text   = palette.overlay2,
            count  = palette.overlay0,
            bg     = palette.surface0,
            gutter = palette.surface2,
            cursor = palette.overlay0,
        }
    end
    if vim.o.background == "dark" then
        return { text = "#9399b2", count = "#6c7086", bg = "#2a2a37", gutter = "#585b70", cursor = "#6c7086" }
    end
    return { text = "#6c6f85", count = "#8c8fa1", bg = "#e6e9ef", gutter = "#acb0be", cursor = "#8c8fa1" }
end

local function set_highlights()
    local c = resolve_colors()
    local bg = M.opts.background and c.bg or "NONE"
    vim.api.nvim_set_hl(0, "Folded", { fg = c.text, bg = bg })
    vim.api.nvim_set_hl(0, "FoldColumn", { fg = c.gutter, bg = "NONE" })
    vim.api.nvim_set_hl(0, "CursorLineFold", { fg = c.cursor, bg = "NONE" })
    vim.api.nvim_set_hl(0, "FoldCount", { fg = c.count, bg = bg, italic = true })
end

-- Width available for the fold line, minus the number/sign/fold columns.
local function text_width()
    local win = vim.api.nvim_get_current_win()
    local info = vim.fn.getwininfo(win)[1]
    return vim.api.nvim_win_get_width(win) - (info and info.textoff or 0)
end

-- Re-derive the treesitter highlights for a single line, so a closed fold keeps
-- its syntax colors. Nvim has no public API for this (`vim.treesitter.foldtext`
-- does not exist), so we run the "highlights" query ourselves.
---@return table[]|nil chunks of { text, highlight }
local function syntax_chunks(bufnr, lnum)
    local line = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1]
    if not line or line == "" then return nil end

    local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
    if not ok or not parser then return nil end

    local query = vim.treesitter.query.get(parser:lang(), "highlights")
    if not query then return nil end

    local tree = parser:parse({ lnum - 1, lnum })[1]
    if not tree then return nil end

    -- Captures overlap (a @function.call range can contain a @punctuation one),
    -- so resolve per column and let the later capture win, as the real
    -- highlighter does, then coalesce equal neighbours back into runs.
    local groups = {}
    for id, node in query:iter_captures(tree:root(), bufnr, lnum - 1, lnum) do
        local srow, scol, erow, ecol = node:range()
        local from = srow == lnum - 1 and scol or 0
        local to = erow == lnum - 1 and ecol or #line
        local hl = "@" .. query.captures[id]
        for col = from, to - 1 do groups[col] = hl end
    end

    local chunks = {}
    local start, current = 0, groups[0] or "Folded"
    for col = 1, #line do
        local hl = groups[col] or "Folded"
        if hl ~= current then
            chunks[#chunks + 1] = { line:sub(start + 1, col), current }
            start, current = col, hl
        end
    end
    chunks[#chunks + 1] = { line:sub(start + 1), current }
    return chunks
end

---@return table[]|string chunks of { text, highlight } for the closed fold line
function M.foldtext()
    local lnum = vim.v.foldstart
    local count = vim.v.foldend - lnum + 1
    local suffix = M.opts.suffix(count)

    local chunks
    if M.opts.syntax_highlight then
        local ok, res = pcall(syntax_chunks, vim.api.nvim_get_current_buf(), lnum)
        if ok then chunks = res end
    end
    if not chunks then
        chunks = { { vim.fn.getline(lnum), "Folded" } }
    end

    -- truncate the code so the summary always stays on screen
    local target = text_width() - vim.fn.strdisplaywidth(suffix)
    local out, width = {}, 0
    for _, chunk in ipairs(chunks) do
        local text = chunk[1]
        local w = vim.fn.strdisplaywidth(text)
        if width + w <= target then
            out[#out + 1] = chunk
            width = width + w
        else
            out[#out + 1] = { vim.fn.strcharpart(text, 0, math.max(target - width, 0)), chunk[2] }
            break
        end
    end

    out[#out + 1] = { suffix, "FoldCount" }
    return out
end

function M.setup(opts)
    M.opts = vim.tbl_extend("force", M.opts, opts or {})

    vim.o.foldtext = "v:lua.require'config.folds'.foldtext()"
    vim.o.foldcolumn = M.opts.foldcolumn
    if M.opts.start_open then
        vim.o.foldlevel = 99
        vim.o.foldlevelstart = 99
    end

    -- the default `fold:·` fills the rest of a closed fold with dots.
    -- foldopen/foldclose/foldsep must be exactly one character wide.
    vim.opt.fillchars:append({ fold = " ", foldopen = "▾", foldclose = "▸", foldsep = "│" })

    set_highlights()
    vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("FoldLook", { clear = true }),
        callback = set_highlights,
    })
end

return M
