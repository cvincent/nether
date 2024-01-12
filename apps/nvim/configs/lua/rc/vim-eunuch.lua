-- if packer_plugins["vim-eunuch"] then
  vim.keymap.set("n", "<leader>fm", ":Move ")
  vim.keymap.set("n", "<leader>ffm", ":Move <cr>=expand('%')<cr>")
  vim.keymap.set("n", "<leader>fu", ":Unlink<cr>")
-- end
