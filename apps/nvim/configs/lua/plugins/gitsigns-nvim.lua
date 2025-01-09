return {
  "lewis6991/gitsigns.nvim",

  opts = {
    signs = {
      add          = { text = "+" },
      change       = { text = "~" },
      delete       = { text = "-" },
      topdelete    = { text = "-" },
      changedelete = { text = "-" },
    },

    signs_staged = {
      add          = { text = "→" },
      change       = { text = "↔" },
      delete       = { text = "←" },
      topdelete    = { text = "←" },
      changedelete = { text = "←" },
    },

    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      vim.keymap.set("n", "<leader>gB", gs.toggle_current_line_blame)
      vim.keymap.set("n", "]g", gs.next_hunk)
      vim.keymap.set("n", "[g", gs.prev_hunk)
    end,
  },

  dependencies = {
    "nvim-lua/plenary.nvim",
  },
}
