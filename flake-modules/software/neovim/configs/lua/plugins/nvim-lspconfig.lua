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

    lspconfig.lua_ls.setup({})
    lspconfig.cssls.setup({})
    -- lspconfig.tailwindcss.setup({})
    lspconfig.ts_ls.setup({})

    lspconfig.nixd.setup({
      cmd = { "nixd" },
      settings = {
        nixd = {
          -- TODO: Pull dotfiles path from Nix config
          nixpkgs = { expr = "import (builtins.getFlake \"/home/cvincent/dotfiles\").inputs.nixpkgs { }" },
          -- formatting = { "nixfmt" },
          options = {
            nixos = { expr = "(builtins.getFlake \"/home/cvincent/dotfiles\").nixosConfigurations.nether.options { }" },
            home_manager = { expr = "(builtins.getFlake \"/home/cvincent/dotfiles\").homeConfigurations.nether.options { }" }
          }
        }
      }
    })

    lspconfig.nil_ls.setup({})

    lspconfig.elixirls.setup({
      cmd = { "elixir-ls" },
      settings = {
        dialyzerEnabled = true,
        incrementalDialyzer = true,
        suggestSpecs = true,
        signatureAfterComplete = true,
        enableTestLenses = true
      },
      on_attach = function(client)
        -- client.server_capabilities.definitionProvider = false
        client.server_capabilities.referencesProvider = false
      end
    })

    lspconfig.nextls.setup({
      cmd = { "nextls", "--stdio" },
      init_options = {
        extensions = {
          credo = { enable = true }
        },
        experimental = {
          completions = { enable = true }
        }
      },
      on_attach = function(client)
        client.server_capabilities.definitionProvider = false
        -- client.server_capabilities.referencesProvider = false
      end
    })

    lspconfig.ruby_lsp.setup({
      init_options = {
        formatter = "rubocop_internal",
        linters = { "rubocop_internal" },
      }
    })

    lspconfig.rust_analyzer.setup({})

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

    -- `d`iagnostic `f`loat
    vim.keymap.set("n", "<leader>df", function()
      vim.diagnostic.open_float()
      vim.diagnostic.config(default_diagnostic_config)
      vim.b.diagnostic_detail = false
    end)

    local opts = { noremap = true, silent = true }

    -- Navigate diagnostics
    vim.api.nvim_set_keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev({ float = false })<CR>", opts)
    vim.api.nvim_set_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next({ float = false })<CR>", opts)

    -- Go to definition
    vim.api.nvim_set_keymap("n", "gf", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
    vim.api.nvim_set_keymap("n", "gV", "<c-w>vgf", { noremap = false, silent = true })
    vim.api.nvim_set_keymap("n", "gs", "<c-w>sgf", { noremap = false, silent = true })
  end
}
