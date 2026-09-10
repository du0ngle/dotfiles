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

        -- Keep stepping in code that has source: step into skips std:: and
        -- gtest (testing::) internals, and stepping out of a test body runs
        -- on instead of stopping in libgtest, which has no debug info.
        local lldb_step_settings = {
            "settings set target.process.thread.step-avoid-regexp ^(std|testing)::",
            "settings set target.process.thread.step-out-avoid-nodebug true",
        }
        -- codelldb breaks on every C++ throw by default (cpp_throw), even when
        -- the code catches it, and stops inside libstdc++ with no source.
        -- :lua require("dap").set_exception_breakpoints() turns it back on.
        dap.defaults.codelldb.exception_breakpoints = {}

        -- The dap console evaluates C++ as typed, like VS's Immediate Window:
        -- console mode "evaluate", with LLDB's native C++ evaluator so calls like
        -- a.Value() work (codelldb's default one can't call functions). LLDB
        -- commands need a leading backtick (`bt).
        dap.listeners.on_config["codelldb_settings"] = function(config)
            if config.type ~= "codelldb" then
                return config
            end
            local commands = vim.list_extend(vim.deepcopy(config.initCommands or {}), lldb_step_settings)
            local adapter_settings = vim.tbl_extend("force", config._adapterSettings or {}, { consoleMode = "evaluate" })
            return vim.tbl_extend("force", config, {
                initCommands = commands,
                _adapterSettings = adapter_settings,
                expressions = config.expressions or "native",
            })
        end

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
        }

        -- Virtual text
        require("nvim-dap-virtual-text").setup()

        -- DAP UI
        -- In the call stack, <CR> jumps to the frame (dap-ui only maps "o" for
        -- that). Other panels keep <CR> for expanding variables.
        dapui.setup({
            element_mappings = {
                stacks = { open = { "<CR>", "o" } },
            },
        })
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

        -- Jump to a dap-ui panel: its window if the layout is open, else a float.
        local function focus_element(name)
            local buf = dapui.elements[name].buffer()
            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                if vim.api.nvim_win_get_buf(win) == buf then
                    vim.api.nvim_set_current_win(win)
                    return
                end
            end
            dapui.float_element(name, { enter = true })
        end

        vim.keymap.set("n", "<leader>di", function()
            focus_element("repl")
            vim.cmd("startinsert!")
        end, { desc = "Focus debug console" })
        vim.keymap.set("n", "<leader>dc", function() focus_element("stacks") end, { desc = "Focus call stack" })
        vim.keymap.set("n", "<leader>dw", function() focus_element("watches") end, { desc = "Focus watches" })

        vim.keymap.set("n", "<leader>db", dap.step_back, { desc = "Step back" })
        vim.keymap.set("n", "<leader>dC", dap.clear_breakpoints, { desc = "Clear breakpoints" })

        vim.keymap.set("n", "<leader>d<Up>", ":lua dap.Up()<CR>", { desc = " stacktrace" })
        vim.keymap.set("n", "<leader>d<Down>", ":lua dap.Up()<CR>", { desc = " stacktrace" })

    end
}
