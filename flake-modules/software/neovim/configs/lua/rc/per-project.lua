vim.api.nvim_create_autocmd({ "VimEnter" }, {
  callback = function()
    if vim.g.per_project then
      vim.g.vim_test_tmux_target = vim.g.per_project.tmux_default_target;
      pcall(vim.fn.serverstart, vim.g.per_project.nvr_pipe)
    end
  end,
})
