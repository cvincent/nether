-- if packer_plugins["ack.vim"] then
  vim.g.ackprg = "rg --vimgrep --smart-case"

  vim.keymap.set("n", "<leader>fp", ":Ack! ")
  vim.keymap.set("n", "<leader>fP", ":execute 'Ack! ' . expand('<cword>')<cr>")
-- end
