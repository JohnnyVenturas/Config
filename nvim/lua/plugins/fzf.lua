return {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function ()
        local fzf = require('fzf-lua')
        fzf.setup({
                grep = {
                    rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e ",
                    fzf_opts = {
                        ['--tiebreak'] = 'index'
                    }
                },
        })

		vim.keymap.set('n', '<leader>/', function() fzf.blines({query="'"}) end , { desc = 'Fzf find files' })
		vim.keymap.set('n', '<leader>?', 
            function() 
                local word = vim.fn.expand('<cword>')
                fzf.blines({query="'"..word}) end ,
            { desc = 'Fzf find files' })
		vim.keymap.set('n', '<leader>ff', function() fzf.files({cwd = '.', hidden = true}) end , { desc = 'Fzf find files' })
		vim.keymap.set('n', '<leader>fg', fzf.git_files, { desc = 'Fzf git files' })
		vim.keymap.set('n', '<leader>fb', fzf.buffers, { desc = 'Fzf buffers' })
		vim.keymap.set('n', '<leader>fr', fzf.lsp_references, { desc = 'Fzf references' })
		vim.keymap.set('n', '<leader>fD', fzf.lsp_workspace_diagnostics, { desc = 'Fzf lsp_definitions' })
		vim.keymap.set('n', '<leader>fl', fzf.live_grep, { desc = 'Fzf live grep' })
        vim.keymap.set('n', '<leader>fL', function()
            fzf.live_grep({ search = vim.fn.expand('<cword>') })
        end, { desc = 'Fzf live grep word under cursor' })
		vim.keymap.set('n', '<leader>fh', fzf.help_tags, { desc = 'Fzf help tags' })
		vim.keymap.set('n', '<leader>fe', fzf.diagnostics_document, { desc = 'Fzf help tags' })
		vim.keymap.set('n', '<leader>fw', fzf.tags, { desc = 'Lsp workspace symbols' })
		vim.keymap.set('n', '<leader>ft', fzf.treesitter, { desc = 'Lsp Document Symbols' })
		vim.keymap.set('n', '<leader>ft', fzf.treesitter, { desc = 'Lsp Document Symbols' })
		vim.keymap.set('n', '<leader>fW', 
            function()
                local word = vim.fn.expand('<cword>')
                fzf.tags({ query = "'"..word })
            end,
            { desc = 'Lsp workspace symbols' })
		vim.keymap.set('n', '<leader>fs', fzf.git_status, { desc = 'Lsp Document Symbols' })
		vim.keymap.set('n', '<leader>fc', fzf.git_commits, { desc = 'Lsp Document Symbols' })
        
    end

}
