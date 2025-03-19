vim.opt_local.conceallevel = 2
-- The space gets in the way of easily adding checkboxes
vim.b[0].delimitMate_expand_space = 0
vim.api.nvim_command("set spell")

-- Bullets mappings
vim.keymap.set("i", "<cr>", "<Plug>(bullets-newline)")
vim.keymap.set("i", "<c-cr>", "<cr>", { noremap = true })

vim.keymap.set("n", "o", "<Plug>(bullets-newline)")
vim.keymap.set("n", ">>", "<Plug>(bullets-demote)")
vim.keymap.set("v", ">", "<Plug>(bullets-demote)")
vim.keymap.set("n", "<<", "<Plug>(bullets-promote)")
vim.keymap.set("v", "<", "<Plug>(bullets-promote)")
