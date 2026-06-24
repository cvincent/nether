return {
  "MagicDuck/grug-far.nvim",
  -- Plugin is already lazy
  lazy = false,
  config = function()
    require('grug-far').setup({
    });
  end
}
