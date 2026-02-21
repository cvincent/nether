vim.api.nvim_create_autocmd("filetype", {
  pattern = "vim",
  callback = function()
    if vim.bo.buftype == "nofile" then
      vim.keymap.set("n", "<leader>w", "<cr>", { buffer = true })
    end
  end,
})
