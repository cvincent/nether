return {
  -- Improved paragraph motion. Lines containing only whitespace become targets
  -- for `{` and `}`. Can skip over folds.

  "justinmk/vim-ipmotion",

  init = function()
    vim.g.ip_skipfold = 1
  end,

  config = function()
    -- Need to run _after_ the plugin is loaded.
    vim.keymap.del("s", "{")
  end,
}
