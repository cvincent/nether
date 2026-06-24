return {
  "folke/zen-mode.nvim",

  init = function()
    vim.keymap.set("n", "<leader>z", ":ZenMode<cr>")
  end
}
