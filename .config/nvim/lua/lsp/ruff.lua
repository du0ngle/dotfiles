return function()
  local found = vim.fs.find(
    { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
    { upward = true }
  )[1]
  local root = found and vim.fs.dirname(found) or vim.loop.cwd()

  vim.lsp.start({
    name = "ruff",
    cmd = { "ruff", "server" },
    root_dir = root,
    filetypes = { "python" },
    single_file_support = true,
    on_attach = function(client)
      -- Let pyright own hover; ruff's is much thinner.
      client.server_capabilities.hoverProvider = false
    end,
  })
end
