return {
    'psf/black',
    config = function()
        vim.g.black_fast = 0
        vim.g.black_linelength = 140
        vim.g.black_skip_string_normalization = 1
        vim.g.black_skip_magic_trailing_comma = 1
        vim.api.nvim_set_keymap('n', '<C-f>', '<cmd>Black<CR>', {noremap = true, silent = true})
    end
}
