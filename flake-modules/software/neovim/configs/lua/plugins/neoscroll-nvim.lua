return {
  "karb94/neoscroll.nvim",

  opts = {
    mappings = { "<C-d>", "<C-u>" },
    hide_cursor = true,
  },

  init = function()
    local neoscroll = require("neoscroll")
    local keymap = {
      ["zt"] = function() neoscroll.zt({ half_win_duration = 100 }) end,
      ["zz"] = function() neoscroll.zz({ half_win_duration = 100 }) end,
      ["zb"] = function() neoscroll.zb({ half_win_duration = 100 }) end,

      ["<c-e>"] = function()
        neoscroll.scroll(vim.v.count1, {
          move_cursor = false,
          duration = 100,
        })
      end,

      ["<c-s-y>"] = function()
        neoscroll.scroll(-vim.v.count1, {
          move_cursor = false,
          duration = 100,
        })
      end,
    }

    local modes = { "n", "v", "x" }

    for key, func in pairs(keymap) do
      vim.keymap.set(modes, key, func)
    end
  end,
}
