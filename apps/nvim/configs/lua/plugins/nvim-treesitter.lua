return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
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
