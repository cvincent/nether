vim.opt_local.conceallevel = 2
-- The space gets in the way of easily adding checkboxes
vim.b[0].delimitMate_expand_space = 0
vim.api.nvim_command("set spell")

-- Bullets mappings
vim.keymap.set("i", "<cr>", "<Plug>(bullets-newline)", { buffer = true })
vim.keymap.set("i", "<c-cr>", "<cr>", { noremap = true, buffer = true })

vim.keymap.set("n", "o", "<Plug>(bullets-newline)", { buffer = true })
vim.keymap.set("n", ">>", "<Plug>(bullets-demote)", { buffer = true })
vim.keymap.set("v", ">", "<Plug>(bullets-demote)", { buffer = true })
vim.keymap.set("n", "<<", "<Plug>(bullets-promote)", { buffer = true })
vim.keymap.set("v", "<", "<Plug>(bullets-promote)", { buffer = true })
