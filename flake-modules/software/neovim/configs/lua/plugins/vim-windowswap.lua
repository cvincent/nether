return {
  "wesQ3/vim-windowswap",

  init = function()
    vim.g.windowswap_map_keys = 0
    vim.keymap.set("n", "<c-w>x", ":call WindowSwap#EasyWindowSwap()<cr>")
  end
}
