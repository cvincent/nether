-- if packer_plugins["gitsigns.nvim"] then
  require("gitsigns").setup({
    signs = {
      add          = { hl = "GitSignsAdd"   , text = "+" },
      change       = { hl = "GitSignsChange", text = "~" },
      delete       = { hl = "GitSignsDelete", text = "-" },
      topdelete    = { hl = "GitSignsDelete", text = "-" },
      changedelete = { hl = "GitSignsChange", text = "-" },
    },

    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      vim.keymap.set("n", "<leader>gB", gs.toggle_current_line_blame)
    end
  })
-- end
