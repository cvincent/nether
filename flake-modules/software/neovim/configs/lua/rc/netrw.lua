vim.api.nvim_create_autocmd("FileType", {
  pattern = "netrw",
  command = "nmap <buffer> <c-l> <c-w>l"
})

vim.g.netrw_bufsettings = "noma nomod nu nobl nowrap ro"
