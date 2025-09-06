return {
    "neovim/nvim-lspconfig",
    dependencies = {},
    config = function()
        vim.api.nvim_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', { noremap=true, silent=true })
    end
}
