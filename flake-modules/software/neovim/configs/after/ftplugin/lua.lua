-- Execute the current line of Lua
vim.keymap.set("n", "g==", ":.lua<cr>")
-- Execute the selected lines of Lua
-- TODO: Make this work in normal mode with motions
vim.keymap.set("v", "g=", ":lua<cr>")

local ts_utils = require("ts_utils")

vim.keymap.set("i", "<c-e>", function()
  if ts_utils.find_node_ancestor({ "table_constructor" }, vim.treesitter.get_node()) then
    local keys = vim.api.nvim_replace_termcodes("<space>=<space>,<left>", true, true, true)
    vim.fn.feedkeys(keys)
  else
    vim.fn.feedkeys(" = ")
  end
end)
