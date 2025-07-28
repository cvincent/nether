return {
  "tpope/vim-ragtag",
  -- NOTE: I should actually just call RagtagInit() in after/ftplugin, duh
  init = function()
    vim.api.nvim_create_autocmd("filetype", {
      pattern = "elixir",
      callback = function()
        vim.cmd("call RagtagInit()")
        vim.cmd("source ~/.config/nvim/after/indent/heex.lua")
      end
    })
    vim.api.nvim_create_autocmd("filetype", {
      pattern = "eelixir",
      callback = function()
        vim.cmd("call RagtagInit()")
        vim.cmd("source ~/.config/nvim/after/indent/heex.lua")
      end
    })
    vim.api.nvim_create_autocmd("filetype", {
      pattern = "heex",
      callback = function()
        vim.cmd("call RagtagInit()")
        vim.cmd("source ~/.config/nvim/after/indent/heex.lua")
      end
    })
  end
}
