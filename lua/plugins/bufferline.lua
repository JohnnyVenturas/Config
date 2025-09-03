return {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
        bufferline = require('bufferline')

        bufferline.setup {}
        diagnostics_indicator = function(count, level, diagnostics_dict, context)
            if context.buffer:current() then
                return ''
            end

            return ''
        end
        vim.keymap.set('n', '<C-p>', "<cmd>BufferLineCyclePrev<cr>")
        vim.keymap.set('n', '<C-n>', "<cmd>BufferLineCycleNext<cr>")
    end
}
