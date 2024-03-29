-- if packer_plugins["nvim-lspconfig"] then
  -- local mason = require("mason").setup()

  -- local masonlspconfig = require("mason-lspconfig").setup({
  --   automatic_installation = { exclude = { "elixirls" } }
  -- })

  local lspconfig = require("lspconfig")

  local on_attach = function(client, bufnr)
  end

  local capabilities = vim.lsp.protocol.make_client_capabilities()

  -- if packer_plugins["nvim-cmp"] and packer_plugins["cmp-nvim-lsp"] then
    capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
  -- end

  -- local elixirls_cmd = {vim.fn.expand("~/vendor/elixir-ls/rel/language_server.sh")}
  -- Previously used for a legacy project
  -- local f = io.open(vim.fn.expand("./.use-old-elixir-ls"), "r")
  -- if f ~= nil then
  --   io.close(f)
  --   elixirls_cmd = {vim.fn.expand("~/vendor/elixir-ls-1.8.2-otp-22/release/language_server.sh")}
  -- end

  lspconfig.elixirls.setup({
    cmd = { "elixir-ls" },
    on_attach = on_attach,
    capabilities = capabilities
  })
-- end

-- Always apply LSP keybindings

local opts = { noremap=true, silent=true }

-- Not sure what this does
-- vim.api.nvim_set_keymap("n", "<space>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)

-- Navigate diagnostics
vim.api.nvim_set_keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
vim.api.nvim_set_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)

-- Not sure what this does, conflicts with existing binding
-- vim.api.nvim_set_keymap("n", "<space>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)

-- Go to definition
vim.api.nvim_set_keymap("n", "gf", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)

-- Quickfix references
vim.api.nvim_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)

-- Hover
vim.api.nvim_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)

-- Signature info
vim.api.nvim_set_keymap("n", "gK", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)

-- Refactor rename...not supported in Elixir LS yet :(
vim.api.nvim_set_keymap("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)

-- Format buffer
vim.api.nvim_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", opts)
vim.api.nvim_set_keymap("v", "<space>f", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", opts)

-- Format on save
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp", { clear = true }),
  callback = function(args)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = args.buf,
      callback = function()
        vim.lsp.buf.format {async = false, id = args.data.client_id }
      end,
    })
  end
})
