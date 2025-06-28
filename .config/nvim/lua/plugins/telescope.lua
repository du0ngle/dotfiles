return {
    "nvim-telescope/telescope.nvim",
    keys = { "<leader>ff", "<leader>fF", "<leader>fs" },
    dependencies = {
        {"nvim-lua/plenary.nvim", keys = { "<leader>ff", "<leader>fF", "<leader>fs"} },
    },

    config = function()

        local actions = require('telescope.actions')

        require('telescope').setup{
            defaults = {
                path_display={"smart"},
                file_ignore_patterns = {
                    "lazy%-lock.json"
                },
                layout_strategy = "horizontal",
                layout_config = {
                    vertical = {
                        prompt_position = "bottom",
                        width = 1.0,
                        height = 1.0,
                        preview_width = 1.0,
                    },
                },
                sorting_strategy = "ascending",
            },
            pickers = {
                find_files = {
                    previewer = true,
                    attach_mappings = function(_, map)
                        local actions = require('telescope.actions')
                        map('n', '<S-j>', actions.preview_scrolling_down)
                        map('n', '<S-k>', actions.preview_scrolling_up)
                        map('n', '<S-h>', actions.preview_scrolling_left)
                        map('n', '<S-l>', actions.preview_scrolling_right)
                        return true
                    end,
                },
            },
        }

        local builtin = require('telescope.builtin')

        -- FUZZY SEARCH
        vim.keymap.set('n', '<leader>ff', builtin.find_files, {}, { desc = "Find file" })
        vim.keymap.set('n', '<leader>fF', builtin.git_files, {}, { desc = "Find (hidden) file" })
        vim.keymap.set('n', '<leader>fs', function()
            builtin.grep_string({ search = vim.fn.input("Grep > ") });
        end, { desc = "Find string" })

    end
}




