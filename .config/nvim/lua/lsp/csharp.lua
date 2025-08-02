return function()
  vim.lsp.start({
    name = "csharp-ls",
    cmd = { "csharp-ls" },
    root_dir = vim.fs.dirname(
      vim.fs.find({ "*.sln", ".git" }, { upward = true })[1]
    ),
    filetypes = { "cs" },
  })
end

