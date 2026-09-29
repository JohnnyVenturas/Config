-- Obsidian-flavoured markdown rendering.
-- The full option reference lives at :h render-markdown.txt — only the values
-- that differ from the defaults are kept here.
return {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    ft = { 'markdown' },
    config = function()
        -- Catppuccin palette, with a Mocha fallback so this file stands alone.
        local ok, palettes = pcall(require, 'catppuccin.palettes')
        local c = ok and palettes.get_palette() or {
            base = '#1e1e2e', mantle = '#181825', crust = '#11111b',
            surface0 = '#313244', surface1 = '#45475a', surface2 = '#585b70',
            overlay0 = '#6c7086', overlay1 = '#7f849c', overlay2 = '#9399b2',
            subtext0 = '#a6adc8', text = '#cdd6f4',
            lavender = '#b4befe', mauve = '#cba6f7', blue = '#89b4fa',
            sapphire = '#74c7ec', sky = '#89dceb', teal = '#94e2d5',
            flamingo = '#f2cdcd', yellow = '#f9e2af',
        }

        -- Mix `fg` into `bg` at `alpha`, used for the tinted heading blocks.
        local function blend(fg, bg, alpha)
            local function rgb(hex)
                return tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16)
            end
            local fr, fgc, fb = rgb(fg)
            local br, bgc, bb = rgb(bg)
            local function mix(a, b)
                return math.floor(a * alpha + b * (1 - alpha) + 0.5)
            end
            return ('#%02x%02x%02x'):format(mix(fr, br), mix(fgc, bgc), mix(fb, bb))
        end

        -- Obsidian keeps headings in one cool family rather than a rainbow.
        local heading_colors = { c.lavender, c.mauve, c.blue, c.sapphire, c.sky, c.teal }

        local function highlights()
            local hl = vim.api.nvim_set_hl
            for i, color in ipairs(heading_colors) do
                hl(0, 'RenderMarkdownH' .. i, { fg = color, bold = true })
                hl(0, 'RenderMarkdownH' .. i .. 'Bg', {
                    fg = color,
                    bg = blend(color, c.base, 0.13),
                    bold = true,
                })
            end
            hl(0, 'RenderMarkdownCode', { bg = c.mantle })
            hl(0, 'RenderMarkdownCodeInline', { bg = c.surface0, fg = c.flamingo })
            hl(0, 'RenderMarkdownCodeBorder', { bg = c.mantle })
            hl(0, 'RenderMarkdownInlineHighlight', { bg = blend(c.yellow, c.base, 0.30), fg = c.text })
            hl(0, 'RenderMarkdownBullet', { fg = c.overlay2 })
            hl(0, 'RenderMarkdownDash', { fg = c.surface2 })
            hl(0, 'RenderMarkdownLink', { fg = c.blue })
            hl(0, 'RenderMarkdownWikiLink', { fg = c.lavender })
        end

        highlights()
        vim.api.nvim_create_autocmd('ColorScheme', {
            group = vim.api.nvim_create_augroup('MarkdownHighlights', { clear = true }),
            callback = highlights,
        })

        -- Soft wrap on prose, the way a note editor behaves.
        vim.api.nvim_create_autocmd('FileType', {
            group = vim.api.nvim_create_augroup('MarkdownProse', { clear = true }),
            pattern = 'markdown',
            callback = function()
                vim.opt_local.wrap = true
                vim.opt_local.linebreak = true
                vim.opt_local.breakindent = true
                vim.opt_local.breakindentopt = ''
                vim.opt_local.showbreak = '  '
            end,
        })

        require('render-markdown').setup({
            -- Renders in every mode, including insert: Obsidian's live preview.
            -- Only the line under the cursor falls back to raw markdown.
            preset = 'obsidian',
            completions = { lsp = { enabled = false } },
            anti_conceal = { enabled = true, above = 0, below = 0 },
            -- No gutter decorations, Obsidian has no equivalent.
            sign = { enabled = false },
            heading = {
                sign = false,
                position = 'inline',
                icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
                width = 'block',
                right_pad = 2,
                border = false,
            },
            code = {
                sign = false,
                width = 'block',
                left_pad = 2,
                right_pad = 2,
                border = 'thin',
                -- Language label sits top-right, as it does in Obsidian.
                position = 'right',
                language_pad = 1,
                inline_pad = 1,
            },
            bullet = {
                icons = { '•', '◦', '▸', '▪' },
                left_pad = 0,
                right_pad = 1,
            },
            checkbox = {
                unchecked = { icon = '󰄱 ' },
                checked = { icon = '󰄲 ' },
                custom = {
                    todo = { raw = '[-]', rendered = '󰥔 ', highlight = 'RenderMarkdownTodo' },
                },
            },
            quote = {
                icon = '▎',
                repeat_linebreak = true,
            },
            pipe_table = {
                preset = 'round',
                cell = 'trimmed',
            },
            link = {
                wiki = { icon = '󰌹 ', highlight = 'RenderMarkdownWikiLink' },
            },
            -- ==text== rendered as a highlighter pen, an Obsidian extension.
            inline_highlight = { enabled = true },
            latex = { enabled = true },
        })
    end,
}
