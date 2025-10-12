-- Execute the current line of Lua
vim.keymap.set("n", "g==", ":.lua<cr>")
-- Execute the selected lines of Lua
-- TODO: Make this work in normal mode with motions
vim.keymap.set("v", "g=", ":lua<cr>")
