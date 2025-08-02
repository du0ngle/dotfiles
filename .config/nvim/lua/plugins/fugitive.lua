return {
    "tpope/vim-fugitive",
    ft = { "cs", "python", "tex", "txt", "xml", "lua", "markdown", "cpp" },

    config = function()

        -- Git status, and git diffs
        vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Status" })
        vim.keymap.set("n", "<leader>gds", vim.cmd.Gdiffsplit, { desc = "Git diff split" })
        vim.keymap.set("n", "<leader>gdm", ":Gdiffsplit -- master<CR>", { desc = "Git diff master"})
        vim.keymap.set("n", "<leader>gdb", function()
            local user_input = vim.fn.input("Branch name > ")
            vim.api.nvim_command(":Gdiffsplit -- " .. user_input)
        end, {desc = "Git diff branch_name"})


        -- Create and delete local branches. 
        -- NOTE: For safety issues, deleting remote branches can only be done manually on the website.
        vim.keymap.set("n", "<leader>gCb", function()
            local user_input_existing_branch = vim.fn.input("Choose existing branch to duplicate  > ")
            local user_input_new_branch_name = vim.fn.input("Create branch name > ")
            vim.api.nvim_command(":!git checkout " .. user_input_existing_branch)
            vim.api.nvim_command(":!git branch " .. user_input_new_branch_name)
            vim.api.nvim_command(":!git checkout " .. user_input_new_branch_name)
            vim.api.nvim_command(":!git push -u origin " .. user_input_new_branch_name)
        end, {desc = "Create new branch, check it out, and push to remote"})

        vim.keymap.set("n", "<leader>gDb", function()
            local user_input = vim.fn.input("DELETE MERGED local branch name > ")
            vim.api.nvim_command(":!git checkout master")
            vim.api.nvim_command(":!git branch -d " .. user_input)
        end, {desc = "Delete local branch"})

        vim.keymap.set("n", "<leader>gDB", function()
            local user_input = vim.fn.input("FORCE DELETE UNMERGED local branch name > ")
            vim.api.nvim_command(":!git checkout master")
            vim.api.nvim_command(":!git branch -D " .. user_input)
        end, {desc = "FORCE!! Delete local branch"})


        -- Git blame, add, push, pull, log, and commit
        vim.keymap.set("n", "<leader>gb", ":Git blame<CR>", { desc = "Git blame" })
        vim.keymap.set("n", "<leader>ga", ":Git add -- .<CR>", { desc = "Git add all" })
        vim.keymap.set("n", "<leader>gpl", ":Git pull<CR>", { desc = "Git pull" })
        vim.keymap.set("n", "<leader>gps", ":Git push<CR>", { desc = "Git push" })
        vim.keymap.set("n", "<leader>gl", ":Git log<CR>", { desc = "Git log" })
        vim.keymap.set("n", "<leader>gco", function()
            local user_input = vim.fn.input("Commit message > ")
            vim.api.nvim_command(":!git commit -m '" .. user_input .. "'")
        end, { desc = "Git commit message" })
        vim.keymap.set("n", "<leader>gch", function()
            local user_input = vim.fn.input("Checkout branch > ")
            vim.api.nvim_command(":!git checkout " .. user_input)
        end, { desc = "Git checkout" })


        -- Telescope
        vim.keymap.set("n", "<leader>fgb", ":Telescope git_branches<CR>", { desc = "Branches"})
        vim.keymap.set("n", "<leader>fgC", ":Telescope git_commits<CR>" , { desc = "All commits" })
        vim.keymap.set("n", "<leader>fgc", ":Telescope git_bcommits<CR>", { desc = "Current file commits" })


    end

}
