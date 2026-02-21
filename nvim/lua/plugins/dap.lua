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
            --
            local mason_path  = vim.fn.stdpath('data') .. '/mason'

            dap.adapters.debugpy = {
                type = "executable",
                command = mason_path .. '/bin/debugpy-adapter'
            }

            dap.configurations.python = {
                {
                    type = 'debugpy',
                    request = 'launch',
                    name = "Launch file",
                    program = "${file}",
                    pythonPath = function()
                        return vim.fn.exepath('python3')
                    end,
                },
                {
                    type = 'debugpy',
                    request = 'launch',
                    name = "Launch file with arguments",
                    program = "${file}",
                    pythonPath = function()
                        return vim.fn.exepath('python3')
                    end,
                    args=function ()
                        local args_string = vim.fn.input("Arguments:")
                        return vim.split(args_string, " +")
                    end,
                },
            }

            local gdb = vim.fn.exepath("gdb")
            local lldb                = vim.fn.exepath("lldb")
            --- local debuger= os.env("CXX_DEBUGGER")

            dap.adapters.cppdbg          = {
                type = "executable",
                command = mason_path .. '/bin/codelldb'
            }


            -- Configure how to debug C++ programs
            -- local debugger

            -- local get_debugger = function ()
            --     if not debugger then 
            --         debugger = vim.fn.input("Select Debugger: (gdb | lldb) ")
            --         return debugger
            --     else
            --         return debugger
            --     end
            -- end
            
            -- local MIMode = function()
            --
            --     local debugger = get_debugger()
            --
            --     if debugger ~= 'gdb' and debugger ~= 'lldb' then
            --         error("Unknown debugger" .. debugger)
            --     end
            --
            --     return debugger
            -- end

            -- local miDebuggerPath = function ()
            --     return vim.fn.exepath(get_debugger())
            -- end


            dap.configurations.cpp = {
                {
                    type = "cppdbg",
                    request = "launch",
                    name = "Debug CPP Program",
                    -- THIS IS THE KEY PART - tells debugger which program to run
                    program = function()
                        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                    end,
                    cwd =  vim.fn.getcwd(),
                    stopAtEntry = true,
                    -- Move these to top level (not nested under OS)
                    MIMode = 'lldb',
                    miDebuggerPath = vim.fn.exepath('lldb'),
                } , {
                    type = "cppdbg",
                    request = "launch",
                    name = "Debug CPP Program with arguments",
                    -- THIS IS THE KEY PART - tells debugger which program to run
                    program = function()
                        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                    end,
                    cwd = vim.fn.getcwd(),
                    stopAtEntry = true,
                    -- Move these to top level (not nested under OS)
                    MIMode = 'lldb',
                    miDebuggerPath = vim.fn.exepath('lldb'),
                    args = function ()
                        local args = vim.fn.input("Arguments (enter for no arguments): ") 
                        return vim.split(args, " +")
                    end
                } 
            }


            -- Also set up for C files
            dap.configurations.c = dap.configurations.cpp


            
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
            vim.keymap.set("n", "<leader>dc", dap.continue)
            vim.keymap.set("n", "<leader>dsi", dap.step_into)
            vim.keymap.set("n", "<leader>dn", dap.step_over)
            vim.keymap.set("n", "<leader>dso", dap.step_out)
            vim.keymap.set("n", "<leader>dsb", dap.step_back)
            vim.keymap.set("n", "<leader>dsr", dap.restart)
            vim.keymap.set("n", "<leader>du", dap.up)
            vim.keymap.set("n", "<leader>dd", dap.down)


            
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

