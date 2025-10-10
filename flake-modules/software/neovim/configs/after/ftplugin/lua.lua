-- Execute the current line of Lua
vim.keymap.set("n", "g==", ":.lua<cr>")
-- Execute the selected lines of Lua
vim.keymap.set("v", "g=", ":lua<cr>")
