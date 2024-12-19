-- Execute the current line of Lua
vim.keymap.set("n", "<leader>x", ":.lua<cr>")
-- Execute the selected lines of Lua
vim.keymap.set("v", "<leader>x", ":lua<cr>")
