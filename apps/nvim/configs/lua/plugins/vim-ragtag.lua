return {
  "tpope/vim-ragtag",
  init = function()
    vim.api.nvim_create_autocmd("filetype", {
      pattern = "elixir",
      command = "call RagtagInit()"
    })
    vim.api.nvim_create_autocmd("filetype", {
      pattern = "eelixir",
      command = "call RagtagInit()"
    })
    vim.api.nvim_create_autocmd("filetype", {
      pattern = "heex",
      command = "call RagtagInit()"
    })
  end
}
