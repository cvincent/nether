return {
  "tpope/vim-unimpaired",
  init = function()
    -- Up/down create newlines
    vim.keymap.set("n", "<down>", "]<space>", { remap = true })
    vim.keymap.set("n", "<up>", "[<space>", { remap = true })
  end
}
