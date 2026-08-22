return function()
  local found = vim.fs.find(
    { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".venv", ".git" },
    { upward = true }
  )[1]
  local root = found and vim.fs.dirname(found) or vim.loop.cwd()

  -- Point pyright at the project venv so it can resolve installed packages.
  local venv = vim.env.VIRTUAL_ENV or (vim.uv.fs_stat(root .. "/.venv") and root .. "/.venv")

  vim.lsp.start({
    name = "pyright",
    cmd = { "pyright-langserver", "--stdio" },
    root_dir = root,
    filetypes = { "python" },
    single_file_support = true,
    settings = {
      python = {
        pythonPath = venv and (venv .. "/bin/python") or nil,
        analysis = {
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = "openFilesOnly",
        },
      },
    },
  })
end
