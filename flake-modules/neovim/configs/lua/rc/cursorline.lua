vim.api.nvim_create_autocmd({"VimEnter", "WinEnter", "BufWinEnter"}, {
  pattern = "*",
  command = "setlocal cursorline"
})

vim.api.nvim_create_autocmd("WinLeave", {
  pattern = "*",
  command = "setlocal nocursorline"
})
