# nvim config notes

Reference for the modules under `lua/config/` that aren't plugin specs. Plugin
configuration lives in `lua/plugins/` and is loaded by lazy.nvim; everything
listed here is plain Lua wired up directly from `init.lua`.

Leader is `,` (`lua/config/basic.lua`).

```
init.lua
├── config.basic           options + core keymaps
├── config.header_source   gh  -> jump between .c/.h counterparts
├── config.lazy            plugin manager bootstrap
├── config.mru      *      persistent recently-opened files
├── config.folds    *      fold appearance
└── config.terminal *      terminals, send-to-terminal, zoom
```

`*` = documented below.

---

## Pickers

fzf-lua is the picker (`lua/plugins/fzf.lua`). Additions to the existing `<leader>f*` family:

| Key | Picker |
|---|---|
| `<leader>fj` | Jumplist — the `C-o`/`C-i` history, filterable |
| `<leader>fm` | All marks |
| `<leader>fB` | Fuzzy-search lines across **all open buffers** (`<leader>/` is the current buffer only) |
| `<leader>fo` | Recently opened files, jumps to the position you left off at |

`fj`/`fm`/`fB` are fzf-lua builtins (`jumps`, `marks`, `lines`). `fo` is backed
by `config.mru`.

Marks and the jumplist already persist across sessions via nvim's shada file —
nothing extra needed for those.

---

## `config.mru` — recently opened files

Tracks every real file you open, most-recently-opened first, along with the
cursor position you left it at. Persisted so it survives restarts.

- **Data file:** `~/.local/share/nvim/mru.json` (`stdpath("data")`)
- **Picker:** `<leader>fo`, or `require('config.mru').pick()`
- **List:** `require('config.mru').list()`

Paths are stored absolute and normalized, which matters because
`basic.lua` sets `autochdir`, so the cwd moves with the buffer.

### Concurrent nvim instances

`save()` doesn't blindly overwrite. It re-reads the file and merges: this
instance's ordering wins, files only the other instance saw are appended, and
where both touched a file the newer cursor position (by `ts`) is kept. Saves are
debounced 2s and also run on `VimLeavePre`.

### Options

```lua
require('config.mru').setup({
  path             = vim.fn.stdpath("data") .. "/mru.json",
  max              = 500,      -- files remembered
  restore_on_open  = false,    -- see below
  ignore_filetypes = { "gitcommit", "gitrebase", "help", "qf" },
})
```

`restore_on_open` is **off** by default. `<leader>fo` always jumps to the
remembered position; this option additionally makes *every* file open jump
there. That's a change to how the editor behaves everywhere, hence opt-in.

Buffers with a non-empty `buftype`, URI-style names, and paths that aren't
regular files are skipped.

---

## `config.folds` — fold appearance

The fold *method* is not set here — that's `lua/plugins/tree_sitter.lua:119-122`
(treesitter `foldexpr`). This module only controls how a closed fold is drawn.

Before: catppuccin's `Folded` painted the whole line flat blue (`#89b4fa`), the
default `foldtext()` prefixed `+--` dashes, and `fillchars=fold:·` padded the
rest of the line with dots.

Now:

```
local function index_of(list, path)  󰁂 5 lines
└──── real per-token syntax colors ──┘  └── dim gray italic ──┘
```

- `Folded` → gray on a subtle bar; `FoldCount` → dim italic for the summary
- Colors are read from the live catppuccin palette, with a standalone
  light/dark fallback, and reapplied on `ColorScheme`
- Code is truncated so the `N lines` summary stays visible in narrow windows

### Options

```lua
require('config.folds').setup({
  syntax_highlight = true,
  suffix     = function(count) return ("  󰁂 %d lines"):format(count) end,
  background = true,     -- false = fully transparent fold line
  foldcolumn = "0",      -- "1" or "auto:1" to show the fold gutter
  start_open = false,    -- see below
})
```

### Gotchas found while building this

- **`vim.treesitter.foldtext()` does not exist** in nvim 0.11 — it is not in the
  `vim.treesitter` module. The first implementation called it, and the `pcall`
  silently swallowed the error and fell back to flat coloring. The highlighting
  is therefore built by hand: run the `highlights` query for the line, resolve
  overlapping captures per column (later capture wins, as the real highlighter
  does), then coalesce equal neighbours back into runs.
- **`fillchars` `foldopen`/`foldclose`/`foldsep` must be exactly one character.**
  Multi-codepoint nerd-font glyphs throw `E1511` and abort `setup()` partway,
  which silently leaves the highlights unapplied.
- **`tree_sitter.lua:122` sets `foldlevel = 0`**, so files open fully collapsed.
  That's behaviour rather than looks, so it was left alone —
  `setup({ start_open = true })` flips it.
- **nvim-ufo is installed** (it's in `lazy-lock.json`) but fully commented out in
  `lua/plugins/folds.lua`. Uncomment that file for virtual-text folds and a peek
  window.

---

## `config.terminal` — terminals, sending, zoom

| Key | Mode | Action |
|---|---|---|
| `<leader>tt` | n | Toggle terminal (bottom split, 30% height) |
| `<leader>ts` | n | Send current line |
| `<leader>ts` | x | Send visual selection |
| `<leader>tr` | n | Resend last sent text |
| `<leader>tk` | n | Kill terminal |
| `<leader>z` | n, x | Zoom window, tmux-style |
| `<C-h/j/k/l>` | t | Move between windows straight from terminal mode |

Also `:TermSend <text>`.

All terminal commands take a count: `2<leader>tt` toggles a second, independent
shell. Terminals are keyed by that id.

- **Toggle** hides/shows rather than recreating — the same process and scrollback
  come back.
- **Send** opens the terminal if needed and returns focus to where you were, so
  you can fire off lines without leaving the buffer. `<leader>tr` is the one to
  reach for: send a build/test command once, then re-run it while editing.
- **Zoom** saves the layout with `winrestcmd()` and restores it exactly on the
  second press. Per-tabpage, keeps the focused window.

### Terminal-mode navigation

`<C-h/j/k/l>` route through `nvim-tmux-navigation`, same as normal mode, so they
cross into tmux panes at the edges (with a `wincmd` fallback if the plugin isn't
loaded).

Navigating back into a terminal you left this way drops you into terminal mode
automatically. But if you deliberately pressed `<C-\><C-n>` to read scrollback,
leaving and returning keeps you in **normal** mode — the flag is cleared on
`TermLeave`, so it won't yank you into insert while you're reading output.

Non-obvious: the resume flag is set *after* `navigate()`, because the window
switch itself fires `TermLeave`, which would otherwise immediately clear a flag
set beforehand.

`<C-\>` is deliberately never mapped in terminal mode — it would shadow
`<C-\><C-n>`.

**Tradeoff:** those four keys no longer reach programs inside the terminal, so no
`C-l` clear-screen or `C-k` kill-line there. `tmux.conf` loads
`christoomey/vim-tmux-navigator`, which binds them at the tmux root level, so
they were already unavailable in every other pane — this closes an
inconsistency rather than opening one. `clear` still works, `C-u` still kills
the line.

### Options

```lua
require('config.terminal').setup({
  size          = 0.3,      -- split height as a fraction of the screen
  shell         = nil,      -- defaults to 'shell'
  start_insert  = true,
  close_on_exit = true,
  esc_esc       = false,    -- see below
  terminal_nav  = { "<C-h>", "<C-j>", "<C-k>", "<C-l>" },
})
```

`terminal_nav = { "<M-h>", "<M-j>", "<M-k>", "<M-l>" }` uses Alt instead and
leaves all four control keys to the shell; `false` disables it.

`esc_esc` maps `<Esc><Esc>` to leave terminal mode. **Off** by default: it makes
a lone `<Esc>` wait `timeoutlen` (1s) before reaching the program, which is
miserable in nested `vim`, `less`, or git's pager. `<C-\><C-n>` always works.

### If you move to a tmux-pane REPL

`M.send()` is the only function that targets the nvim terminal. Sending to a
tmux pane instead (vim-slime style) means changing that one function.

---

## Testing notes

Most of this is verifiable with `nvim --headless -c 'lua ...' -c 'qa!'`.

Two exceptions worth remembering:

- **Terminal mode is unreachable under `--headless`** (no UI attached).
  `mode()` reports `n` no matter what you feed it, so keypress tests there prove
  nothing. To test it for real, run nvim in a pty and drive it:

  ```sh
  tmux -L nvtest -f /dev/null new-session -d -x 120 -y 40 "nvim --listen /tmp/nvt.sock file"
  tmux -L nvtest send-keys C-k
  nvim --server /tmp/nvt.sock --remote-expr 'mode()'
  ```

  `-f /dev/null` is important — otherwise the real tmux config's
  vim-tmux-navigator bindings intercept `C-h/j/k/l` before nvim ever sees them.

- **`foldtext` only runs during real fold rendering.** `v:foldstart` is `0`
  outside that, so calling the function directly returns garbage. Use
  `foldtextresult(lnum)` to trigger a genuine render (it flattens to a string;
  to inspect the highlight chunks, wrap the function and log what it returns).
