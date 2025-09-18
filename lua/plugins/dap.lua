return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "leoluz/nvim-dap-go",
            "rcarriga/nvim-dap-ui",
            "theHamsta/nvim-dap-virtual-text",
            "nvim-neotest/nvim-nio",
            "williamboman/mason.nvim",
        },
        config = function()
            local dap = require "dap"
            local ui = require "dapui"
            
            -- Set up UI and Go debugging
            require("dapui").setup()
            require("dap-go").setup()
            
            -- Check if gdb is available
            local gdb = vim.fn.exepath "gdb"
            if gdb ~= "" then
                -- Set up the debug adapter (the bridge between Neovim and gdb)
                dap.adapters.cppdbg = {
                    type = "executable",
                    command = vim.fn.stdpath('data') .. '/mason/bin/OpenDebugAD7'
                }
                
                -- Configure how to debug C++ programs
                dap.configurations.cpp = {
                    {
                        type = "cppdbg",
                        request = "launch",
                        name = "Launch CPP Program",
                        -- THIS IS THE KEY PART - tells debugger which program to run
                        program = function()
                            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                        end,
                        cwd = '${workspaceFolder}',
                        stopAtEntry = true,
                        -- Move these to top level (not nested under OS)
                        MIMode = "gdb",
                        miDebuggerPath = "/usr/bin/gdb"
                    }
                }
                
                -- Also set up for C files
                dap.configurations.c = dap.configurations.cpp
            end
            
            -- Custom breakpoint symbol
            vim.fn.sign_define('DapBreakpoint', {text='🛑', texthl='', linehl='', numhl=''})
            
            -- Key mappings for debugging
            vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint)
            vim.keymap.set("n", "<leader>drc", dap.run_to_cursor)
            vim.keymap.set("n", "<leader>?", function()
                ui.eval(nil, { enter = true })
            end)

            vim.keymap.set("v", "<leader>?", function()
                ui.eval(nil, {enter = true})
            end)

            vim.keymap.set("n", "<leader>dt", function()
                ui.toggle()
            end)
            vim.keymap.set("n", "<F1>", dap.continue)
            vim.keymap.set("n", "<F2>", dap.step_into)
            vim.keymap.set("n", "<F3>", dap.step_over)
            vim.keymap.set("n", "<F4>", dap.step_out)
            vim.keymap.set("n", "<F5>", dap.step_back)
            vim.keymap.set("n", "<F12>", dap.restart)
            
            -- Automatically open/close debug UI
            dap.listeners.before.attach.dapui_config = function()
                ui.open()
            end
            dap.listeners.before.launch.dapui_config = function()
                ui.open()
            end
            dap.listeners.before.event_terminated.dapui_config = function()
                ui.close()
            end
            dap.listeners.before.event_exited.dapui_config = function()
                ui.close()
            end
        end,
    },
}

