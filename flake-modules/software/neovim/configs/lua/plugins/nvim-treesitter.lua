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
          -- Treesitter indent doesn't handle list continuations well
          disable = { "markdown" }
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
            },

            goto_previous_start = {
              ["[a"] = "@parameter.outer",
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
}
