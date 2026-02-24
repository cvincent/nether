-- Disabling this for now. These replace our command line shortcuts with opening
-- the command window instead. Main sticking point is lack of completion of
-- initial command (though completion for command args does seem to work).
-- vim.keymap.set("n", "<cr>", "q:i")
-- vim.keymap.set("v", "<cr>", "q:a")

-- Our classic command line shortcuts
vim.keymap.set("n", "<cr>", ":")
vim.keymap.set("v", "<cr>", ":")

vim.api.nvim_create_autocmd("CmdWinEnter", {
  callback = function()
    local ui = vim.api.nvim_list_uis()[1]

    vim.api.nvim_win_set_config(0, {
      relative = "laststatus",
      width = ui.width,
      height = 4,
      row = 0,
      col = 0,
    })

    vim.keymap.set("i", "<c-c>", "<c-o>0<c-o>D<cr>", { buffer = true })
    vim.keymap.set("n", "<leader>w", "<cr>", { buffer = true })
    vim.keymap.set("n", "<c-c>", vim.cmd.close, { buffer = true })
    vim.keymap.set("n", "<esc>", vim.cmd.close, { buffer = true })
    vim.keymap.set("n", "q", vim.cmd.close, { buffer = true })
  end,
})
