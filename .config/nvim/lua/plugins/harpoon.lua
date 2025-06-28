return {
    "ThePrimeagen/harpoon",
    keys = { "<leader>1", "<leader>2", "<leader>3", "<leader>4" },

    config = function()
        local mark = require("harpoon.mark")
        local ui = require("harpoon.ui")

        vim.keymap.set("n", "<leader>hh", mark.add_file, { desc = "Add file" })
        vim.keymap.set("n", "<C-h>", ui.toggle_quick_menu, { desc = "Open harpoon menu" })

        vim.keymap.set("n", "<leader>1", function() ui.nav_file(1) end, { desc = "Go to file 1" })
        vim.keymap.set("n", "<leader>2", function() ui.nav_file(2) end, { desc = "Go to file 2" })
        vim.keymap.set("n", "<leader>3", function() ui.nav_file(3) end, { desc = "Go to file 3" })
        vim.keymap.set("n", "<leader>4", function() ui.nav_file(4) end, { desc = "Go to file 4" })
    end
}
