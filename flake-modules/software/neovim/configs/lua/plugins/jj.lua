return {
  "avm99963/vim-jjdescription",

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
