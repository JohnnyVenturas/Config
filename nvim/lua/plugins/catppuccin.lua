return { 
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
        require("catppuccin").setup({
            flavour = "auto", -- latte, frappe, macchiato, mocha
            background = { -- :h background
                light = "latte",
                dark = "mocha",
            },
            transparent_background = transparent_mode, -- disables setting the background color.
            float = {
                transparent = true,  -- enable transparent floating windows
                solid = true,        -- use solid styling for floating windows, see |winborder|
            },
            show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
            term_colors = false,      -- sets terminal colors (e.g. `g:terminal_color_0`)
            dim_inactive = {
                enabled = false,      -- dims the background color of inactive window
                shade = "dark",
                percentage = 0.15,    -- percentage of the shade to apply to the inactive window
            },
            no_italic = false,        -- Force no italic
            no_bold = false,          -- Force no bold
            no_underline = false,     -- Force no underline
            styles = {                -- Handles the styles of general hi groups (see `:h highlight-args`):
                comments = { "italic" }, -- Change the style of comments
                conditionals = {},
                loops = {},
                functions = {},
                keywords = {},
                strings = { "italic" },
                variables = {},
                numbers = {},
                booleans = {},
                properties = {},
                types = {},
                operators = {},
                -- miscs = {}, -- Uncomment to turn off hard-coded styles
            },
            color_overrides = {},
            custom_highlights = {},
            custom_highlights = function(colors)
                return {
                    Comment = { fg = colors.purple },
                    TabLineSel = { bg = colors.pink },
                    CmpBorder = { fg = colors.surface2 },
                    Pmenu = { bg = colors.none },
                }
            end,
            default_integrations = true,
            auto_integrations = true,
            integrations = {
                cmp = true,
                gitsigns = true,
                nvimtree = true,
                treesitter = true,
                notify = false,
                mini = {
                    enabled = true,
                    indentscope_color = "",
                },
                -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
            }
        })
        vim.cmd.colorscheme "catppuccin"

        -- Also override the K mapping to ensure consistency
        vim.keymap.set('n', 'K', function()
            vim.lsp.buf.hover({ border = "single" })
        end, { desc = "LSP Hover with Border" })

        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
            vim.lsp.handlers.hover, {
                border = "shadow" -- Drop shadow effect
            }
        )
    end

}
