return {
  "tpope/vim-surround",
  init = function()
    vim.keymap.set("v", "s", "S", { remap = true })
  end
}
