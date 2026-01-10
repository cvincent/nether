vim.wo.foldlevel = 99
vim.wo.foldtext = "getline(v:foldstart)"
vim.o.fillchars = "fold:⋅"
vim.o.foldcolumn = "0"

vim.keymap.set("n", "z<space>", function()
  vim.wo.foldlevel = vim.fn.foldlevel(vim.fn.line(".") - 1)
end)
