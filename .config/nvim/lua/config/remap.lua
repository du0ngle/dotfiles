-- Set leader key
vim.g.mapleader = " "

-- Filetree
vim.keymap.set("n", "<leader>o", vim.cmd.Ex)

-- Save and quit
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Write" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit window" })
vim.keymap.set("n", "<leader>Q", ":bd | exit<CR>", { desc = "Delete buffer and exit" })

-- Move selected stuff with arrow keys
vim.keymap.set("v", "<Down>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<Up>", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "<Right>", ">gv")
vim.keymap.set("v", "<Left>", "<gv")

-- Jumps while still having linecursor centered in the middle
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Copy paste over word, still has the copied value on the clipboard
vim.keymap.set("x", "<leader>p", "\"_dP")

-- For every common string, replace
vim.keymap.set("n", "<leader>/", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Split panels
vim.keymap.set("n", "<leader>v", ":vsplit<CR>")
vim.keymap.set("n", "<leader>s", ":split<CR>")

-- Adjust panel size
vim.keymap.set("n", "=","5<C-w>>")
vim.keymap.set("n", "-","5<C-w><")
vim.keymap.set("n", "_","5<C-w>+")
vim.keymap.set("n", "+","5<C-w>-")

-- Move between panels
vim.keymap.set("n", "<leader>h", "<C-W>h", { desc = "Move left split"})
vim.keymap.set("n", "<leader>j", "<C-W>j", { desc = "Move lower split"})
vim.keymap.set("n", "<leader>k", "<C-W>k", { desc = "Move upper split"})
vim.keymap.set("n", "<leader>l", "<C-W>l", { desc = "Move right split"})

-- Move between buffers (similar to tabs)
vim.keymap.set("n", "<S-Tab>", ":bnext<CR>")
vim.keymap.set("n", "<Tab>", ":bprevious<CR>")

-- Cancel highlighting after incremental search by using ESC
vim.keymap.set("n", "<esc>", ":noh<CR>")

-- Cursor always in middle of screen
vim.keymap.set("n", "k", "kzz")
vim.keymap.set("n", "j", "jzz")
vim.keymap.set("v", "k", "kzz")
vim.keymap.set("v", "j", "jzz")
vim.keymap.set("n", "<C-j>", "<PageDown>zz")
vim.keymap.set("n", "<C-k>", "<PageUp>zz")
vim.keymap.set("v", "<C-j>", "<PageDown>zz")
vim.keymap.set("v", "<C-k>", "<PageUp>zz")

-- -- Toggle diff split-viewer 
-- local diffState = false
-- local function toggleDiff()
--     vim.api.nvim_command(diffState and "windo diffoff" or "windo diffthis")
--     diffState = not diffState
-- end
-- vim.keymap.set("n", "<leader>D", toggleDiff, { desc = "Diff split view" })

-- Open terminal in split view
vim.keymap.set("n", "<leader>T", function() vim.api.nvim_command(":vertical terminal") end, { desc = "Open terminal in split view" })

-- Go normal mode in terminal
vim.api.nvim_set_keymap('t', '<ESC>', '<C-\\><C-n>', { noremap = true })

-- Open PMV files
vim.keymap.set("n", "<leader>ft", ":1ToggleTerm<Enter>icd 'C:/Temp/PMVToolingReleases/'<enter>fzfcdo<enter><C-v><Enter>", { desc = "Open tools in split view" })
vim.keymap.set("n", "<leader>fl", ":1ToggleTerm<Enter>icd 'C:/Temp/Logs'<enter>fzfv<enter>", { desc = "Open logs" })
vim.keymap.set("n", "<leader>fi", ":1ToggleTerm<Enter>icd 'C:/Users/Duong/OneDrive - Raboweb/PMV internal/'<enter>fzfo<enter>", { desc = "Open PMV internal" })
vim.keymap.set("n", "<leader>fe", ":1ToggleTerm<Enter>icd 'C:/Users/Duong/OneDrive - Raboweb/PMV external/'<enter>fzfo<enter>", { desc = "Open PMV external" })

-- Copy current directory, file to clipboard
vim.api.nvim_set_keymap('n', '<leader>Yd', '<cmd>let @*=expand("%:p:h")<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>Yf', '<cmd>let @+=expand("%:p")<CR>', { noremap = true, silent = true })
