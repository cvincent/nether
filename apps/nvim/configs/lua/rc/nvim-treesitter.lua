-- if packer_plugins["nvim-treesitter"] then
  require "nvim-treesitter.configs".setup {
    -- Automatically install missing parsers when entering buffer
    auto_install = true,

    ensure_installed = {"elixir", "heex"},

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
      enable = true
    }
  }

  vim.opt.foldmethod = "expr"
  vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
  vim.opt.foldenable = false
-- end
