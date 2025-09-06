return {
    "hrsh7th/nvim-cmp",
    dependencies = {
        'neovim/nvim-lspconfig',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-cmdline',
        'L3MON4D3/LuaSnip',
        'saadparwaiz1/cmp_luasnip'
    },
    config = function()
        -- Configure diagnostics
        vim.diagnostic.config({
            virtual_text = false, -- Disable inline virtual text
            signs = true,         -- Show signs in the sign column
            underline = false,     -- Underline diagnostic text
            update_in_insert = true,
            severity_sort = true,
            float = {
                border = 'rounded',
                source = 'always',  -- Show diagnostic source
                header = '',
                prefix = '',
                focusable = true,   -- Make float window focusable
            }
        })

        -- Set up diagnostic navigation keymaps
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic' })
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic' })
        vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic in float window' })
        vim.keymap.set('n', '<leader>q', vim.diagnostic.setqflist, { desc = 'Open diagnostic quickfix list' })

        
        -- nvim-cmp setup
        
        --signcolumn must be on the left
        vim.opt.signcolumn = "yes"
        luasnip = require('luasnip')
        local cmp = require'cmp'
        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body)
                end,
            },
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete(),
                ["<Tab>"] = cmp.mapping.select_next_item({ behavior = cmp.ConfirmBehavior.Insert }),
                ['<C-n>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item({behavior = cmp.ConfirmBehavior.Insert})
                        return
                    end

                    if luasnip.jumpable(1) then
                        luasnip.jump(1)
                    else
                        cmp.complete()
                    end
                end, {'i', 's'}),
                ['<C-p>'] = cmp.mapping(function(fallback)

                    if cmp.visible() then
                        cmp.select_prev_item({behavior = cmp.ConfirmBehavior.Insert})
                        return
                    end

                    if luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        cmp.complete()

                    end
                end,{'i', 's'}),
                ['<C-e>'] = cmp.mapping.abort(),
                --['<CR>'] = cmp.mapping.confirm({ select = true }), 
                ['<CR>'] = cmp.mapping(
                    function(fallback)
                        if cmp.visible() then
                            cmp.confirm({ select = true })
                        else
                            fallback()
                        end
                    end)

            }),
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'luasnip' }, 
                { name = 'buffer' }
            })
        })
        
        cmp.setup.cmdline({ '/', '?' }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = 'buffer' }
            }
        })
        
        cmp.setup.cmdline(':', {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                { name = 'path' }
            }, {
                { name = 'cmdline' }
            }),
            matching = { disallow_symbol_nonprefix_matching = false }
        })
    end
}

