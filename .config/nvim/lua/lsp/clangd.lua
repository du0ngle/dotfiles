return function()
  vim.lsp.start({
    name = "clangd",
    cmd = { "clangd" },
    root_dir = vim.fs.dirname(
      vim.fs.find({ "compile_commands.json", ".git" }, { upward = true })[1]
    ),
    filetypes = { "c", "cpp" },
  })
end
