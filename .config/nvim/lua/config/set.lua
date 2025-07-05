vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.o.ignorecase = true
vim.o.smartcase = true

vim.opt.autoindent = true
vim.opt.smartindent = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.updatetime = 50

vim.opt.clipboard = "unnamedplus"

vim.g.netrw_bufsettings = 'noma nomod nu nowrap ro nobl'

vim.opt.cursorline = true
vim.opt.hlsearch = true

vim.opt.fixeol = false

vim.api.nvim_create_augroup('highlight_yank', {})
vim.api.nvim_create_autocmd('TextYankPost', {
  group = 'highlight_yank',
  callback = function()
    vim.hl.on_yank({higroup='IncSearch', timeout=150})
  end,
})

vim.opt.tags = { './tags', '../tags',  './ctags', '../ctags',  './.tags', '../.tags',  './.ctags', '../.ctags'}
