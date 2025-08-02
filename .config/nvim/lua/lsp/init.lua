--------- Keymaps ---------
require("lsp.keymaps").setup()

-- General settings
vim.diagnostic.config({
  virtual_text = true,
})

--------- C++ ---------
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  callback = require("lsp.clangd"),
})


-- Set .tpp files to use cpp filetype (for Tree-sitter)
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.tpp",
  callback = function()
    vim.bo.filetype = "cpp"
  end,
})

-- Detach LSP from .tpp files
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufname = vim.api.nvim_buf_get_name(args.buf)
    if bufname:match("%.tpp$") then
      vim.schedule(function()
        vim.lsp.buf_detach_client(args.buf, args.data.client_id)
      end)
    end
  end,
})


--------- C# ---------
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "cs" },
  callback = require("lsp.csharp"),
})
