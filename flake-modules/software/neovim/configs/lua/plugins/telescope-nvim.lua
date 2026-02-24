return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "master",

    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-live-grep-args.nvim",
      "natecraddock/telescope-zf-native.nvim",
      "nvim-telescope/telescope-symbols.nvim",
      {
        "anekos/tailiscope.nvim",
        branch = "fix/support-case-sensitive-filesystems"
      },
    },

    opts = function()
      require("telescope")
      local telescope_actions = require("telescope.actions")
      local lga_actions = require("telescope-live-grep-args.actions")

      return {
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

                ["<c-s>"] = "select_horizontal",
                ["<c-x>"] = "nop",

                ["<c-q>"] = function(prompt_bufnr)
                  local actions = telescope_actions
                  actions.smart_send_to_qflist(prompt_bufnr)
                  actions.open_qflist(prompt_bufnr)
                end,

                ["<c-s-q>"] = function(prompt_bufnr)
                  local actions = telescope_actions
                  actions.smart_add_to_qflist(prompt_bufnr)
                  actions.open_qflist(prompt_bufnr)
                end,

                ["<c-space>"] = telescope_actions.to_fuzzy_refine,
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
              anchor_padding = -1,
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
              i = { ["<cr>"] = telescope_actions.git_switch_branch }
            },
          },

          lsp_document_symbols = {
            symbol_width = 0.75,
          },
        },

        extensions = {
          tailiscope = {
            register = "c",
          },

          live_grep_args = {
            auto_quoting = true,
            mappings = {
              i = {
                ["<c-k>"] = lga_actions.quote_prompt(),
              },
            },
          },
        },
      }
    end,

    init = function()
      local telescope = require("telescope")
      local telescope_actions = require("telescope.actions")
      local telescope_builtin = require("telescope.builtin")

      local custom_telescopes_pickers = require("custom_telescopes.pickers")
      local live_grep_args_shortcuts = require("telescope-live-grep-args.shortcuts")

      local maps = {
        fs = telescope_builtin.lsp_document_symbols,
        ff = telescope_builtin.find_files,
        fb = telescope_builtin.buffers,
        fh = telescope_builtin.help_tags,
        fe = telescope_builtin.symbols,
        fk = telescope_builtin.keymaps,
        fT = telescope_builtin.builtin,
        ft = custom_telescopes_pickers.tmux_files,
        fg = telescope.extensions.live_grep_args.live_grep_args,
        fG = live_grep_args_shortcuts.grep_word_under_cursor,
      }

      local may_change_buffer = {
        "ff", "fb", "fT", "ft", "fg", "fG"
      }

      for map, func in pairs(maps) do
        vim.keymap.set("n", "<leader>" .. map, func)

        if vim.tbl_contains(may_change_buffer, map) then
          vim.keymap.set("n", "<leader>v" .. map, function()
            vim.cmd("vsplit")
            func()
          end)

          vim.keymap.set("n", "<leader>s" .. map, function()
            vim.cmd("split")
            func()
          end)

          vim.keymap.set("n", "<leader>T" .. map, function()
            vim.cmd("tabnew")
            func()
          end)
        end
      end

      vim.keymap.set("n", "<leader>gc", telescope_builtin.git_branches)

      vim.keymap.set(
        "n", "<leader>gm",
        function()
          telescope_builtin.git_branches({
            attach_mappings = function(_, map)
              map("i", "<cr>", telescope_actions.git_merge_branch)
              return true
            end
          })
        end
      )

      telescope.load_extension("live_grep_args")
      telescope.load_extension("tailiscope")
      telescope.load_extension("zf-native")
    end,
  },
}
