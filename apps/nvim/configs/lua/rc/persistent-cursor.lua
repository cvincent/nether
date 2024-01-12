-- I don't know how this works but it do
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*",
  command = [[
    if line("'\"") > 1 && line("'\"") <= line("$") |
      exe "normal! g`\"" |
    endif
  ]]
})
