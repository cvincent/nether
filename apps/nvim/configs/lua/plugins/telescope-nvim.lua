return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",

    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-symbols.nvim",
      { "anekos/tailiscope.nvim",                   branch = "fix/support-case-sensitive-filesystems" },
    },

    opts = {
      defaults = vim.tbl_extend(
        "force",
        require("telescope.themes").get_ivy(),
        {
          mappings = {
            i = {
              ["<c-bs>"] = { "<c-s-w>", type = "command" },
              ["<esc>"] = require('telescope.actions').close,
              ["<c-down>"] = require('telescope.actions').cycle_history_next,
              ["<c-up>"] = require('telescope.actions').cycle_history_prev,
            }
          },
          winblend = 28,
          prompt_prefix = "❯ ",
          selection_caret = "→ ",
          dynamic_preview_title = true,
          results_title = false,
          cache_picker = { num_pickers = -1 },
          layout_strategy = "horizontal",
          layout_config = {
            anchor = "S",
            prompt_position = "top",
            height = 0.4,
            width = 9999,
            mirror = true,
            preview_width = 0.5,
          },
          -- TODO: Make the theme look like our git fugitive window in progress
        }),

      pickers = {
        git_branches = {
          mappings = {
            i = { ["<cr>"] = require("telescope.actions").git_switch_branch }
          },
        },
      },

      extensions = {
        tailiscope = {
          register = "c",
        },
      },
    },

    init = function()
      require("telescope").load_extension("fzf")

      vim.keymap.set("n", "<leader>fs", require("telescope.builtin").lsp_document_symbols)
      vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files)
      vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep)
      vim.keymap.set("n", "<leader>fh", require("telescope.builtin").help_tags)
      vim.keymap.set("n", "<leader>fe", require("telescope.builtin").symbols)

      vim.keymap.set("n", "<leader>gc", require("telescope.builtin").git_branches)

      -- Deprecate these, get used to the new keymaps above
      vim.keymap.set("n", "<c-p>", require("telescope.builtin").find_files)
      vim.keymap.set("n", "<c-f>", require("telescope.builtin").live_grep)

      require("telescope").load_extension("tailiscope")
    end,
  },
}
