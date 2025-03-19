return {
  "tpope/vim-surround",
  init = function()
    vim.keymap.set("v", "s", "S", { remap = true })
    vim.keymap.del("s", "s")
  end
}
