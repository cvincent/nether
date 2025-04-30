vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "tmp.*.erl",
  callback = function()
    vim.bo.filetype = "elixir"
  end
})
