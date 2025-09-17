return {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
      dependencies = { 'nvim-lua/plenary.nvim' },
      config = function() 
	      local builtin = require('telescope.builtin')
		vim.keymap.set('n', '<leader>tf', builtin.find_files, { desc = 'Telescope find files' })
		vim.keymap.set('n', '<leader>tu', function() builtin.find_files({cwd = '~', hidden = true}) end , { desc = 'Telescope find files' })
		vim.keymap.set('n', '<leader>tg', builtin.git_files, { desc = 'Telescope git files' })
		vim.keymap.set('n', '<leader>tb', builtin.buffers, { desc = 'Telescope buffers' })
		vim.keymap.set('n', '<leader>tr', builtin.lsp_references, { desc = 'Telescope references' })
		vim.keymap.set('n', '<leader>td', builtin.lsp_definitions, { desc = 'Telescope references' })
		vim.keymap.set('n', '<leader>ts', builtin.live_grep, { desc = 'Telescope live grep' })
		vim.keymap.set('n', '<leader>th', builtin.help_tags, { desc = 'Telescope help tags' })

        vim.api.nvim_create_autocmd("User", {
            pattern = "TelescopePreviewerLoaded",
            callback = function(args)
                vim.wo.number=true
                vim.wo.relativenumber=true
            end
        })
      end
    
}
