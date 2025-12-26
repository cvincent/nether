return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "master",

    dependencies = {
      "nvim-lua/plenary.nvim",
      -- { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "natecraddock/telescope-zf-native.nvim",
      "nvim-telescope/telescope-symbols.nvim",
      {
        "anekos/tailiscope.nvim",
        branch = "fix/support-case-sensitive-filesystems"
      },
    },

    opts = {
      defaults = vim.tbl_extend(
        "force",
        require("telescope.themes").get_ivy(),
        {
          mappings = {
            i = {
              ["<m-bs>"] = { "<c-s-w>", type = "command" },
              ["<esc>"] = "close",
              ["<c-down>"] = "cycle_history_next",
              ["<c-up>"] = "cycle_history_prev",

              ["<c-q>"] = function(prompt_bufnr)
                local actions = require("telescope.actions")
                actions.smart_send_to_qflist(prompt_bufnr)
                actions.open_qflist(prompt_bufnr)
              end,
            }
          },
          winblend = 15,
          prompt_prefix = "❯ ",
          selection_caret = "→ ",
          dynamic_preview_title = true,
          results_title = false,
          cache_picker = { num_pickers = -1 },
          layout_strategy = "horizontal",
          layout_config = {
            anchor = "S",
            anchor_padding = 0,
            prompt_position = "top",
            height = 0.4,
            width = 9999,
            mirror = true,
            preview_width = 0.5,
          },
          -- TODO: Make the theme look like our git fugitive window in progress
        }),

      pickers = {
        buffers = {
          mappings = {
            i = {
              ["<cr>"] = require("custom_telescopes.actions").find_existing_window,
            },
          },
        },

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
      -- require("telescope").load_extension("fzf")
      require("telescope").load_extension("zf-native")

      vim.keymap.set("n", "<leader>fs", require("telescope.builtin").lsp_document_symbols)
      vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files)
      vim.keymap.set("n", "<leader>fb", require("telescope.builtin").buffers)
      vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep)
      vim.keymap.set("n", "<leader>fh", require("telescope.builtin").help_tags)
      vim.keymap.set("n", "<leader>fe", require("telescope.builtin").symbols)
      vim.keymap.set("n", "<leader>fT", require("telescope.builtin").builtin)

      vim.keymap.set(
        "n", "<leader>fG",
        function()
          require("telescope.builtin").live_grep({ default_text = vim.fn.expand("<cword>") })
        end
      )

      vim.keymap.set("n", "<leader>gc", require("telescope.builtin").git_branches)

      vim.keymap.set(
        "n", "<leader>gm",
        function()
          require("telescope.builtin").git_branches({
            attach_mappings = function(_, map)
              map("i", "<cr>", require("telescope.actions").git_merge_branch)
              return true
            end
          })
        end
      )

      require("telescope").load_extension("tailiscope")
    end,
  },
}
