return {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },  -- Required for async features
    event = "BufReadPost",  -- Load after reading a buffer
    config = function()
        -- Basic options for folding
        vim.o.foldcolumn = "1"  -- Show fold column
        vim.o.foldlevel = 99    -- High level to avoid auto-closing
        vim.o.foldlevelstart = 99
        vim.o.foldenable = true

        -- Custom fold text handler (from your example, with number suffix)
        local function foldVirtTextHandler(virtText, lnum, endLnum, width, truncate)
            local newVirtText = {}
            local suffix = (" 󰁂 %d "):format(endLnum - lnum)
            local sufWidth = vim.fn.strdisplaywidth(suffix)
            local targetWidth = width - sufWidth
            local curWidth = 0
            for _, chunk in ipairs(virtText) do
                local chunkText = chunk[1]
                local chunkWidth = vim.fn.strdisplaywidth(chunkText)
                if targetWidth > curWidth + chunkWidth then
                    table.insert(newVirtText, chunk)
                else
                    chunkText = truncate(chunkText, targetWidth - curWidth)
                    local hlGroup = chunk[2]
                    table.insert(newVirtText, { chunkText, hlGroup })
                    chunkWidth = vim.fn.strdisplaywidth(chunkText)
                    if curWidth + chunkWidth < targetWidth then
                        suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
                    end
                    break
                end
                curWidth = curWidth + chunkWidth
            end
            table.insert(newVirtText, { suffix, "MoreMsg" })
            return newVirtText
        end

        -- Setup with provider chain (LSP -> treesitter -> indent)
        require("ufo").setup({
            fold_virt_text_handler = foldVirtTextHandler,  -- Apply custom handler
            provider_selector = function(bufnr, filetype, buftype)
                local ftMap = {
                    vim = "indent",
                    python = { "indent" },
                    git = "",
                }
                -- Return mapped provider or chain function
                return ftMap[filetype] or function(buf)
                    local function handleFallback(err, provider)
                        if type(err) == "string" and err:match("UfoFallbackException") then
                            return require("ufo").getFolds(buf, provider)
                        else
                            return require("promise").reject(err)
                        end
                    end
                    return require("ufo").getFolds(buf, "lsp")
                        :catch(function(err) return handleFallback(err, "treesitter") end)
                        :catch(function(err) return handleFallback(err, "indent") end)
                end
            end,
            -- Optional: Close certain fold kinds automatically
            close_fold_kinds_for_ft = { default = { "imports", "comment" } },
            preview = {
                win_config = { border = { "", "─", "", "", "", "─", "", "" }, winhighlight = "Normal:Folded", winblend = 0 },
                mappings = { scrollU = "<C-u>", scrollD = "<C-d>" },
            },
        })

        -- Keymaps for folding actions
        vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
        vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
        vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds, { desc = "Open folds except kinds" })
        vim.keymap.set("n", "zm", require("ufo").closeFoldsWith, { desc = "Close folds with level" })
        vim.keymap.set("n", "K", function()
            local winid = require("ufo").peekFoldedLinesUnderCursor()
            if not winid then vim.lsp.buf.hover() end
        end, { desc = "Peek fold or hover" })
    end,
}

