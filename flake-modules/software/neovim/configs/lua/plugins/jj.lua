return {
  "avm99963/vim-jjdescription",

  {
    "nicolasgb/jj.nvim",
    branch = "main",

    dependencies = {
      "toggleterm-fzf", -- Depended on by my config, not the plugin itself
    },

    config = function()
      require("jj").setup({})

      local annotate = require("jj.annotate")
      local file = require("jj.file")

      local picker = require("toggleterm-fzf").picker

      -- By default the plugin puts our cursor in the split to the left when we
      -- close the sidebar. Let's fix it.
      local close_annotate_sidebar = function()
        local sidebar_buf = vim.api.nvim_get_current_buf()
        vim.cmd.wincmd("l")
        vim.api.nvim_buf_delete(sidebar_buf, {})
      end

      vim.keymap.set("n", "<leader>ja", annotate.line, { desc = "JJ annotate line" })

      vim.keymap.set("n", "<leader>jA", function()
        vim.api.nvim_create_autocmd("BufEnter", {
          pattern = "",
          once = true,
          callback = function()
            vim.keymap.set("n", "q", close_annotate_sidebar, { buffer = true })
            vim.keymap.set("n", "<leader>q", close_annotate_sidebar, { buffer = true })
          end,
        })

        annotate.file()
      end, { desc = "JJ annotate file" })

      vim.keymap.set("n", "<leader><c-a>", function()
        local path = vim.fn.expand("%")

        local key_to_split = {
          enter = "",
          ["ctrl-v"] = "wincmd v",
          ["ctrl-s"] = "wincmd s",
          ["ctrl-t"] = "tabnew %",
          ["alt-v"] = "wincmd v",
          ["alt-s"] = "wincmd s",
          ["alt-t"] = "tabnew %",
        }

        picker({
          cmd = NixToNvim.jj.fzf_file_change_ids .. " " .. path,

          expected_keys = {
            "enter",
            "ctrl-v", "ctrl-s", "ctrl-t",
            "alt-v", "alt-s", "alt-t",
          },

          callback = function(key, change_id)
            local diff = key:match("^alt-") ~= nil

            local setup_diff = function()
              if diff then
                vim.cmd.diffthis()
                vim.cmd("set scrollbind")
              end
            end

            vim.api.nvim_create_autocmd("BufEnter", {
              pattern = path,
              once = true,
              callback = vim.schedule_wrap(function()
                setup_diff()

                vim.cmd(key_to_split[key])
                file.open_target({ rev = change_id, path = path, })

                -- Couldn't get an autocommand to trigger, but this works
                vim.defer_fn(setup_diff, 10)
              end),
            })
          end,
        })
      end)
    end,
  },

  {
    "jj-fugitive-toggleterm",
    dev = true,

    dependencies = {
      "tpope/vim-fugitive",
      "toggleterm-fzf",
    },

    opts = {
      command_runner = function(cmd)
        -- Can't pass this function directly because opts are loaded before
        -- per-project globals, which contains our pipe name. Won't be a problem
        -- if we switch to automatically creating a unique pipe name on startup.
        -- However projects which define their own name would still be a problem
        -- because .nvim.lua is loaded late. That said, I think a single NeoVim
        -- instance can have multiple pipes, so...
        require("helpers.tmux-integration").tmux_exec_with_remote_editor(cmd)
      end
    },

    init = function()
      vim.keymap.set("n", "<leader>jj", ":JJWindow<cr>")
      vim.keymap.set("n", "<leader>jn", ":JJNewWindow<cr>")
      vim.keymap.set("n", "<leader>jN", ":JJ new<cr>")
      vim.keymap.set("n", "<leader>ju", ":JJ undo<cr>")
      vim.keymap.set("n", "<leader>jU", ":JJ redo<cr>")
      vim.keymap.set("n", "<leader>js", ":JJ status<cr>")
    end,
  },

  {
    "jj-diffconflicts-nvr",
    dev = true,

    dependencies = {
      "rafikdraoui/jj-diffconflicts",
    },

    opts = {
      conflict_loaded = function()
        vim.keymap.set("n", "<leader>q", ":JJDiffConflictsNvrConclude<cr>", {
          buffer = true,
        })
      end,
    },
  },
}
