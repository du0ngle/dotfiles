return function()
  local found = vim.fs.find({ ".clangd", ".git", "compile_commands.json" }, { upward = true })[1]
  local root = found and vim.fs.dirname(found) or vim.loop.cwd()

  vim.lsp.start({
    name = "clangd",
    cmd = { "clangd", "--background-index" },
    root_dir = root,
    filetypes = { "c", "cpp" },
    single_file_support = true,
  })
end
