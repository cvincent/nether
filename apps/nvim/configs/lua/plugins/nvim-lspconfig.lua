return {
  "neovim/nvim-lspconfig",

  dependencies = {
    -- Automatically handle making the current project's dependencies available
    -- to the Lua LSP; gives us vim api completions!
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },

  init = function()
    local lspconfig = require("lspconfig")

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    if IsPluginInstalled("cmp-nvim-lsp") then
      capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
    end
    capabilities.textDocument.completion.completionItem.snippetSupport = true;

    lspconfig.lua_ls.setup({ capabilities = capabilities })
    lspconfig.cssls.setup({ capabilities = capabilities })
    lspconfig.tailwindcss.setup({ capabilities = capabilities })
    lspconfig.ts_ls.setup({ capabilities = capabilities })

    lspconfig.nixd.setup({
      capabilities = capabilities,
      cmd = { "nixd" },
      settings = {
        nixd = {
          nixpkgs = { expr = "import (builtins.getFlake \"/home/cvincent/dotfiles\").inputs.nixpkgs { }" },
          formatting = { "nixfmt" },
          options = {
            nixos = { expr = "(builtins.getFlake \"/home/cvincent/dotfiles\").nixosConfigurations.nether.options { }" },
            home_manager = { expr = "(builtins.getFlake \"/home/cvincent/dotfiles\").homeConfigurations.nether.options { }" }
          }
        }
      }
    })

    lspconfig.elixirls.setup({
      capabilities = capabilities,
      cmd = { "elixir-ls" }
    })

    lspconfig.gleam.setup({})

    local opts = { noremap = true, silent = true }

    -- Navigate diagnostics
    vim.api.nvim_set_keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
    vim.api.nvim_set_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
    vim.api.nvim_set_keymap("n", "<space>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)

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

    -- Code actions...whatever they are!
    vim.api.nvim_set_keymap("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
  end
}
