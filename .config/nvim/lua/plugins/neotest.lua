-- neotest only runs build/run_test_X, it never compiles. For a tests/test_X.cpp
-- buffer, build that binary first (debug flags, so breakpoints bind), then
-- call `run`. Other buffers run straight away.
-- TODO: replace the g++ call with `make build/run_test_X` once there's a Makefile.
local function build_then(run)
    local file = vim.api.nvim_buf_get_name(0)
    local stem = vim.fs.basename(file):match("^(test_.+)%.cpp$")
    if not stem then
        return run()
    end

    local root = vim.fs.root(file, { "build", ".git" })
    if not root then
        vim.notify("No build/ or .git above " .. file, vim.log.levels.ERROR)
        return
    end

    local sources = vim.fs.find(function(name)
        return name:match("%.cpp$") ~= nil
    end, { path = root .. "/src", type = "file", limit = math.huge })
    local exe = root .. "/build/run_" .. stem
    local cmd = { "g++", "-std=c++17", "-g", "-O0", "-Wall", "-I", root .. "/include", file }
    vim.list_extend(cmd, sources)
    vim.list_extend(cmd, { "-lgtest", "-lgtest_main", "-pthread", "-o", exe })

    vim.fn.mkdir(root .. "/build", "p")
    vim.notify("Building run_" .. stem .. " ...")
    vim.system(cmd, { cwd = root, text = true }, vim.schedule_wrap(function(result)
        if result.code ~= 0 then
            vim.fn.setqflist({}, " ", {
                title = "build run_" .. stem,
                lines = vim.split(result.stderr, "\n", { trimempty = true }),
            })
            vim.cmd("copen")
            vim.notify("Build failed: run_" .. stem, vim.log.levels.ERROR)
            return
        end
        run()
    end))
end

return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        -- Adapters parse test files with treesitter, which is otherwise only
        -- loaded on FileType; pull it in so discovery works from the summary.
        "nvim-treesitter/nvim-treesitter",
        "mfussenegger/nvim-dap",
        "nvim-neotest/neotest-python",
        -- Fork with fixes for nvim 0.11+; upstream alfaix/neotest-gtest is unmaintained.
        { "du0ngle/neotest-gtest", branch = "fix-nvim-0.12" },
    },

    keys = {
        { "<leader>tt", function() build_then(function() require("neotest").run.run() end) end, desc = "Run nearest test" },
        { "<leader>tf", function()
            local file = vim.fn.expand("%:p")
            build_then(function() require("neotest").run.run(file) end)
        end, desc = "Run test file" },
        { "<leader>ta", function() require("neotest").run.run(vim.uv.cwd()) end, desc = "Run all tests" },
        { "<leader>tl", function() require("neotest").run.run_last() end, desc = "Run last test" },
        { "<leader>td", function() build_then(function() require("neotest").run.run({ strategy = "dap" }) end) end, desc = "Debug nearest test" },
        { "<leader>tD", function() require("neotest").run.run_last({ strategy = "dap" }) end, desc = "Debug last test" },
        { "<leader>tx", function() require("neotest").run.stop() end, desc = "Stop test" },
        { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle test summary" },
        { "<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Show test output" },
        { "<leader>tO", function() require("neotest").output_panel.toggle() end, desc = "Toggle test output panel" },
        { "[t", function() require("neotest").jump.prev({ status = "failed" }) end, desc = "Previous failed test" },
        { "]t", function() require("neotest").jump.next({ status = "failed" }) end, desc = "Next failed test" },
    },

    config = function()
        -- gtest: tests/test_X.cpp is built into build/run_test_X, so resolve
        -- executables from that instead of :ConfigureGtest per file.
        -- Executables set with :ConfigureGtest still take priority.
        local gtest_executables = require("neotest-gtest.executables")
        local find_configured = gtest_executables.find_executables

        local function executable_for(path, root)
            local stem = vim.fs.basename(path):gsub("%.[^.]+$", "")
            local exe = root .. "/build/run_" .. stem
            local stat = vim.uv.fs_stat(exe)
            return stat and stat.type == "file" and exe or nil
        end

        gtest_executables.find_executables = function(node)
            local found = find_configured(node)
            if found then
                return found
            end

            local root = node:root():data().path
            local exe2ids, missing = {}, {}
            local function add(data)
                local exe = executable_for(data.path, root)
                if exe then
                    exe2ids[exe] = exe2ids[exe] or {}
                    table.insert(exe2ids[exe], data.id)
                else
                    table.insert(missing, data.id)
                end
            end

            if node:data().type == "dir" then
                for _, child in node:iter_nodes() do
                    local data = child:data()
                    if data.type == "file" and #child:children() > 0 then
                        add(data)
                    end
                end
            else
                -- file, namespace or test: its path is the test file
                add(node:data())
            end

            if #missing > 0 or vim.tbl_isempty(exe2ids) then
                return nil, #missing > 0 and missing or { node:data().id }
            end
            return exe2ids
        end

        require("neotest").setup({
            adapters = {
                require("neotest-python")({
                    runner = "pytest",
                    -- Same interpreter as dap.lua: .venv-devbox inside the box,
                    -- .venv on the host. Returning nil falls back to the
                    -- adapter's own venv detection.
                    python = function(root)
                        local venv = os.getenv("UV_PROJECT_ENVIRONMENT") or ".venv"
                        local python = root .. "/" .. venv .. "/bin/python"
                        return vim.uv.fs_stat(python) and python or nil
                    end,
                    dap = { justMyCode = false },
                }),
                require("neotest-gtest").setup({
                    debug_adapter = "codelldb",
                }),
            },
        })
    end,
}
