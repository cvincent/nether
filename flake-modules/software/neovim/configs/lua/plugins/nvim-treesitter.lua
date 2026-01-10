return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",

    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },

    config = function()
      local opts = {
        auto_install = true,

        ensure_installed = { "elixir", "heex" },

        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },

        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
          },
        },

        indent = {
          enable = true,

          -- NOTE: This takes the parser names, _not_ the filetypes
          disable = {
            -- Treesitter indent doesn't handle list continuations well
            "markdown",
            -- Works poorly in general in Nix files
            "nix",
          }
        },

        textobjects = {
          select = {
            enable = true,

            keymaps = {
              ["ia"] = "@parameter.inner",
              ["aa"] = "@parameter.outer",
              ["im"] = "@function.inner",
              ["am"] = "@function.outer",
            },

            selection_modes = {
              ["@function.inner"] = "V",
              ["@function.outer"] = "V",
            },
          },

          swap = {
            enable = true,

            swap_next = {
              ["<leader>xa"] = "@parameter.inner", -- swap parameters/argument with next
              ["<leader>xm"] = "@function.outer",  -- swap function with next
            },

            swap_previous = {
              ["<leader>xA"] = "@parameter.inner", -- swap parameters/argument with prev
              ["<leader>xM"] = "@function.outer",  -- swap function with previous
            },
          },

          move = {
            enable = true,
            set_jumps = true,

            goto_next_start = {
              ["]a"] = "@parameter.outer",
              ["]m"] = "@function.outer",
            },

            goto_previous_start = {
              ["[a"] = "@parameter.outer",
              ["[m"] = "@function.outer",
            },
          },
        },
      }

      require("nvim-treesitter.configs").setup(opts)
    end,

    init = function()
      vim.opt.foldmethod = "expr"
      vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
      vim.opt.foldenable = false
    end
  },

  "nvim-treesitter/playground",

  {
    "nvim-treesitter/nvim-treesitter-context",

    opts = {
      enable = false,
      multiline_threshold = 1,
    },
  },
}
