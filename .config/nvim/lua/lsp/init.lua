-- Keymaps
require("lsp.keymaps").setup()

-- General settings
vim.diagnostic.config({
  virtual_text = true,
})

-- C++
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  callback = require("lsp.clangd"),
})
