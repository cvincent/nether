return {
  "justinmk/vim-ipmotion",

  init = function()
    vim.g.ip_skipfold = 1
  end,

  config = function()
    -- Need to run _after_ the plugin is loaded.
    vim.keymap.del("s", "{")
  end,
}
