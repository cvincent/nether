vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
    vim.keymap.set("n", "<cr>", "<c-cr>", { buffer = 0 })
  end,
})
