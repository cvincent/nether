return {
  "L3MON4D3/LuaSnip",
  version = "v2.*",
  enabled = true,
  build = "make install_jsregexp",

  opts = {
    store_selection_keys = "<Tab>",
    enable_autosnippets = true,
    region_check_events = "CursorMoved, InsertLeave",
    update_events = "TextChanged,TextChangedI",
  },

  init = function()
    local ls = require("luasnip")

    vim.keymap.set("i", "<C-K>", function()
      if ls.expandable() then
        ls.expand()
      elseif ls.jumpable(1) then
        ls.jump(1)
      end
    end, { silent = true })

    vim.keymap.set("s", "<C-K>", function()
      if ls.jumpable(1) then
        ls.jump(1)
      end
    end)

    vim.keymap.set({ "s", "i" }, "<C-H>", function()
      if ls.jumpable(-1) then
        ls.jump(-1)
      end
    end)

    vim.keymap.set("s", "<bs>", "<c-o>s", { noremap = true })
  end
}
