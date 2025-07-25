return {
  "tpope/vim-surround",
  init = function()
    vim.keymap.set("v", "s", "<Plug>VSurround")
    vim.keymap.del("s", "s")
  end,

  config = function()
    vim.keymap.set("v", "S", function()
      -- TODO: I would like to have a visual mode surround that reselects after,
      -- but there is maybe no way to wait for the surround sequence to finish
      -- before calling `gv`. I will need to dig more deeply into the actual
      -- plugin code.
      -- I created an issue: https://github.com/tpope/vim-surround/issues/392
      CallPlugMapping("VSurround")
      vim.cmd("normal gv")
    end)
  end
}
