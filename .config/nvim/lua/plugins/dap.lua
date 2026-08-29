return {
    "mfussenegger/nvim-dap",
    dependencies = {
        {"rcarriga/nvim-dap-ui"},
        {"nvim-neotest/nvim-nio"},
        {"theHamsta/nvim-dap-virtual-text"},
        {"mfussenegger/nvim-dap-python"}
    },

    config = function()

        local dap, dapui = require("dap"), require("dapui")

        -- Adapters
        dap.adapters.codelldb = {
            type = 'server',
            port = "${port}",
            executable = {
                command = vim.fn.expand("~/tools/codelldb/extension/adapter/codelldb"),
                args = { "--port", "${port}" },
            }
        }

        -- Languages
        dap.configurations.cpp = {
            {
                name = "Launch file",
                type = "codelldb",
                request = "launch",
                program = function()
                    return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                end,
                cwd = '${workspaceFolder}',
                stopOnEntry = false,
                args = {},

                -- Optional: enable pretty-printing for std types
                runInTerminal = false,
            },
        }


        -- Python (debugpy lives in its own venv; the debuggee still runs
        -- with the project's interpreter, resolved by nvim-dap-python)
        local dap_python = require("dap-python")
        dap_python.setup(vim.fn.expand("~/.virtualenvs/debugpy/bin/python"), {
            include_configs = false,
        })

        -- Project root of the current buffer, used as cwd for the debuggee.
        local function project_root()
            return vim.fs.root(0, { "pyproject.toml", "setup.py", "setup.cfg", ".git" })
                or vim.fn.getcwd()
        end

        -- .venv-devbox inside the box, .venv on the host.
        dap_python.resolve_python = function()
            local venv = os.getenv("UV_PROJECT_ENVIRONMENT") or ".venv"
            return project_root() .. "/" .. venv .. "/bin/python"
        end

        dap.configurations.python = {
            {
                name = "Launch file",
                type = "python",
                request = "launch",
                program = "${file}",
                cwd = project_root,
                console = "integratedTerminal",
                justMyCode = false,
            },
            {
                name = "Launch file with args",
                type = "python",
                request = "launch",
                program = "${file}",
                args = function()
                    local input = vim.fn.input("Args: ")
                    return vim.split(input, " ", { trimempty = true })
                end,
                cwd = project_root,
                console = "integratedTerminal",
                justMyCode = false,
            },
            {
                name = "Launch module",
                type = "python",
                request = "launch",
                module = function()
                    return vim.fn.input("Module: ", "trade_explorer.")
                end,
                cwd = project_root,
                console = "integratedTerminal",
                justMyCode = false,
            },
            {
                name = "Attach (remote, port 5678)",
                type = "python",
                request = "attach",
                connect = { host = "127.0.0.1", port = 5678 },
                justMyCode = false,
            },
        }

        -- Virtual text
        require("nvim-dap-virtual-text").setup()

        -- DAP UI
        dapui.setup()
        dap.listeners.before.attach.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
        end

        --Colors for sign
        vim.api.nvim_set_hl(0, 'DapStopped', { ctermbg = 0, fg = '#98c379', bg = '#31353f' })

        --Icons
        vim.fn.sign_define('DapBreakpoint', { text = '🐞' })
        vim.fn.sign_define('DapStopped', { text='', texthl='DapStopped', linehl='DapStopped', numhl= 'DapStopped' })

        -- Debugging shortcuts same as VS
        vim.keymap.set("n", "<F5>", function()
            dap.continue()
            vim.cmd("normal! zz") 
        end, { desc = "Start/continue" })

        vim.keymap.set("n", "<F9>", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })

        vim.keymap.set("n", "<F10>", function()
            dap.step_over()
            vim.cmd("normal! zz")
        end, { noremap = true, silent = true, desc = "Step over" })

        vim.keymap.set("n", "<F11>", function()
            dap.step_into()
            vim.cmd("normal! zz")
        end, { noremap = true, silent = true, desc = "Step into" })

        vim.keymap.set("n", "<F12>", function()
            dap.step_out()
            vim.cmd("normal! zz")
        end, { noremap = true, silent = true, desc = "Step out" })

        vim.keymap.set("n", "<C-d>b", dap.list_breakpoints, { desc = "Show breakpoints" })


        -- Debugging shortcuts w/ <Leader>b
        vim.keymap.set("n", "<leader>dl", dap.restart, { desc = "Restart" })
        vim.keymap.set("n", "<leader>dd", dap.disconnect, { desc = "Disconnect" })
        vim.keymap.set("n", "<leader>drc", dap.run_to_cursor, { desc = "Run to cursor" })

        -- Set the keymap to run to a specific line
        vim.keymap.set("n", "<leader>drl", function () 
            local user_input = vim.fn.input("Line > ") 
            dap.goto_(user_input)
        end, { desc = "Run to line" })

        -- Evaluate variable under cursor
        vim.keymap.set("n", "<leader>?", function() dapui.eval(nil, { enter = true }) end, { desc = "Evaluate" } )

        vim.keymap.set("n", "<leader>db", dap.step_back, { desc = "Step back" })
        vim.keymap.set("n", "<leader>dC", dap.clear_breakpoints, { desc = "Clear breakpoints" })

        vim.keymap.set("n", "<leader>d<Up>", ":lua dap.Up()<CR>", { desc = " stacktrace" })
        vim.keymap.set("n", "<leader>d<Down>", ":lua dap.Up()<CR>", { desc = " stacktrace" })

    end
}
