local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("lazy").setup("plugins",{
    performance = {
        performance = {
            cache = {
                enabled = true,
                path = vim.fn.stdpath("cache") .. "/lazy",
            },
        },
        rtp = {
            -- disabled_plugins = {
                --     "gzip",
                --     "tarPlugin",
                --     "tohtml",
                --     "tutor",
                --     "zipPlugin",
                --     "matchit",
                --     "matchparen",
                --     -- "netrw",
                --     -- "netrwPlugin",
                --     -- "netrwSettings",
                --     -- "netrwFileHandlers",
                -- },
                disabled_plugins = {
                    "gzip",
                    "tarPlugin",
                    "tohtml",
                    "tutor",
                    "zipPlugin",
                    "matchit",
                    "matchparen",
                    "editorconfig",
                    "man",
                    "osc52",
                    "rplugin",
                    "shada",
                    "spellfile",
                    -- "netrw",
                    -- "netrwPlugin",
                    -- "netrwSettings",
                    -- "netrwFileHandlers",
                },

            },
        },
        debug = false,
        -- concurrency = 20, -- Use the number of logical processors
        concurrency = vim.loop.available_parallelism(), -- Set concurrency to the maximum available
    })


