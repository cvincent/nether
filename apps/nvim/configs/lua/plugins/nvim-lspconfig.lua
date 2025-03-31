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
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
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

    local default_diagnostic_config = {
      virtual_text = { current_line = true },
      virtual_lines = false
    }
    vim.diagnostic.config(default_diagnostic_config)

    local diagnostics_augroup = vim.api.nvim_create_augroup("lsp.diagnostics", {})
    vim.api.nvim_create_autocmd("CursorMoved", {
      group = diagnostics_augroup,
      callback = function()
        vim.diagnostic.config(default_diagnostic_config)
        vim.b.diagnostic_detail = false
      end
    })

    -- `d`iagnostic `d`etail
    vim.keymap.set("n", "<leader>dd", function()
      if vim.b.diagnostic_detail then
        vim.diagnostic.config(default_diagnostic_config)
        vim.b.diagnostic_detail = false
      else
        vim.diagnostic.config({
          virtual_text = false,
          virtual_lines = { current_line = true }
        })
        vim.b.diagnostic_detail = true
      end
    end)

    local opts = { noremap = true, silent = true }

    -- Navigate diagnostics
    vim.api.nvim_set_keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev({ float = false })<CR>", opts)
    vim.api.nvim_set_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next({ float = false })<CR>", opts)

    -- Go to definition
    vim.api.nvim_set_keymap("n", "gf", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
  end
}
