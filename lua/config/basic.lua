vim.g.mapleader = ','
vim.api.nvim_set_hl(0, 'BufferLineBufferSelected', { bg = 'none', italic = true })
vim.api.nvim_set_hl(0, 'BufferLineBuffer', { bg = 'none', italic = true })
vim.api.nvim_set_hl(0, 'TabLineSel', { bg = 'none', italic = true })


local opts = { noremap = true, silent = true }

--vim movements between windows
vim.api.nvim_set_keymap('n', '<C-h>', '<C-w>h', opts)
vim.api.nvim_set_keymap('n', '<C-j>', '<C-w>j', opts)
vim.api.nvim_set_keymap('n', '<C-k>', '<C-w>k', opts)
vim.api.nvim_set_keymap('n', '<C-l>', '<C-w>l', opts)


-- Copy selected text to system clipboard
vim.api.nvim_set_keymap('v', '<C-c>', '"+y', opts)



--Paste from system clipboard in insert mode
--vim.api.nvim_set_keymap('i', '<C-S-v>', '<Esc>"+pa', opts)


-- for some reason, on windows terminals c-v directly pastes and does not enable block mode
vim.api.nvim_set_keymap('n', '<C-v>', '<C-q>', { noremap = true, silent = true })


vim.cmd('set relativenumber')




