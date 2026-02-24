return {
  "avm99963/vim-jjdescription",

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
