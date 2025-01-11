-- Alt-t to open a new tab
vim.keymap.set("n", "<a-t>", ":tabnew<cr>")

-- Navigate tabs with arrows
vim.keymap.set("n", "<right>", ":tabnext<cr>")
vim.keymap.set("n", "<left>", ":tabprev<cr>")

-- Move tabs with ctrl-arrows
vim.keymap.set("n", "<c-right>", ":tabmove +1<cr>")
vim.keymap.set("n", "<c-left>", ":tabmove -1<cr>")

-- Spaces, not tabs
vim.opt.expandtab = true

-- Tab stop is 2 spaces by default
vim.opt.tabstop = 2
vim.opt.softtabstop = 2

-- 2 spaces for <</>> indentation
vim.opt.shiftwidth = 2
vim.opt.shiftround = true
