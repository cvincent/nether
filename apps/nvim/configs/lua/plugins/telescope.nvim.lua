return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    opts = {
      defaults = {
        mappings = {
          i = {
            ["<c-bs>"] = { "<c-s-w>", type = "command" },
            ["<esc>"] = require('telescope.actions').close
          }
        },
        winblend = 28,
        layout_config = {
          width = 0.6;
          height = 0.6;
        }
      },
    pickers = {
      git_branches = {
        mappings = {
          i = { ["<cr>"] = require("telescope.actions").git_switch_branch }
        }
      }
    }
    },

    init = function()
      require("telescope").load_extension("fzf")

      vim.keymap.set("n", "<c-p>", require("telescope.builtin").find_files)
      vim.keymap.set("n", "<c-f>", require("telescope.builtin").live_grep)
      vim.keymap.set("n", "<leader>gc", require("telescope.builtin").git_branches)
    end,
  },

  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
}
