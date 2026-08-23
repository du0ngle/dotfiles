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


--------- Python ---------
-- pyright: types, completion, navigation. ruff: lint + format.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python" },
  callback = require("lsp.python"),
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python" },
  callback = require("lsp.ruff"),
})

local function ruff_source_action(bufnr, kind, timeout_ms)
  local client = vim.lsp.get_clients({ bufnr = bufnr, name = "ruff" })[1]
  if not client then
    return
  end

  local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
  params.context = { only = { kind }, diagnostics = {} }

  local responses = client:request_sync("textDocument/codeAction", params, timeout_ms, bufnr)
  if not responses or not responses.result then
    return
  end

  for _, action in ipairs(responses.result) do
    -- The server may hand back a stub that needs resolving before it has edits.
    if not action.edit and action.data then
      local resolved = client:request_sync("codeAction/resolve", action, timeout_ms, bufnr)
      action = resolved and resolved.result or action
    end
    if action.edit then
      vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
    end
  end
end

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.py",
  callback = function(args)
    ruff_source_action(args.buf, "source.organizeImports.ruff", 2000)

    vim.lsp.buf.format({
      bufnr = args.buf,
      timeout_ms = 2000,
      filter = function(client)
        return client.name == "ruff"
      end,
    })
  end,
})
