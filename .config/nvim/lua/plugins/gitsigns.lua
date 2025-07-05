return {
    "lewis6991/gitsigns.nvim",
    ft = { "cs", "python", "tex", "txt", "xml", "lua", "markdown" },

    config = function()
        require('gitsigns').setup {
            signs = {
                add          = { text = '┃'},
                change       = { text = '┃'},
                delete       = { text = '┃'},
                topdelete    = { text = '┃'},
                changedelete = { text = '┃'},
                untracked    = { text = '┃'},
            },
            signcolumn = true,
        }

        -- Define highlight groups for Git signs
        vim.cmd [[
        highlight GitSignsAdd guifg=#00ff00 guibg=NONE
        highlight GitSignsChange guifg=#ffff00 guibg=NONE
        highlight GitSignsDelete guifg=#ff0000 guibg=NONE
        ]]
    end

}
