return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    opts = {
      defaults = {
        mappings = {
          i = {
            ["<c-bs>"] = { "<c-s-w>", type = "command" },
            ["<esc>"] = require('telescope.actions').close,
            ["<c-down>"] = require('telescope.actions').cycle_history_next,
            ["<c-up>"] = require('telescope.actions').cycle_history_prev,
          }
        },
        winblend = 28,
        theme = "ivy",
        prompt_prefix = "❯ ",
        selection_caret = "→ ",
        dynamic_preview_title = true,
        results_title = false,
        cache_picker = { num_pickers = -1 },
      },
      pickers = {
        lsp_document_symbols = {
          theme = "ivy",
        },
        find_files = {
          theme = "ivy",
        },
        live_grep = {
          theme = "ivy",
        },
        git_branches = {
          theme = "ivy",
          mappings = {
            i = { ["<cr>"] = require("telescope.actions").git_switch_branch }
          },
        },
        help_tags = {
          theme = "ivy",
        },
      },
    },

    init = function()
      require("telescope").load_extension("fzf")

      vim.keymap.set("n", "<leader>fs", require("telescope.builtin").lsp_document_symbols)
      vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files)
      vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep)
      vim.keymap.set("n", "<leader>fh", require("telescope.builtin").help_tags)

      vim.keymap.set("n", "<leader>gc", require("telescope.builtin").git_branches)

      -- Deprecate these, get used to the new keymaps above
      vim.keymap.set("n", "<c-p>", require("telescope.builtin").find_files)
      vim.keymap.set("n", "<c-f>", require("telescope.builtin").live_grep)
    end,

    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
  },
}
