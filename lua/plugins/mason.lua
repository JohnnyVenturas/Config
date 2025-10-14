return {
    "mason-org/mason.nvim",
    opts = {},
    config = function()
        require("mason").setup(
            {
                ui = {
                    border = 'rounded'
                }
            }
        )
    end



}
