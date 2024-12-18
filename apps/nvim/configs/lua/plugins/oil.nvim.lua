return {
  "stevearc/oil.nvim",
  lazy = false,
  init = function()
    vim.api.nvim_set_keymap("n", "-", "<cmd>Oil<cr>", {})
  end
}
