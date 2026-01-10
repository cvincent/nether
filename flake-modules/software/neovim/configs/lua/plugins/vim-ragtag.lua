return {
  "tpope/vim-ragtag",
  init = function()
    vim.api.nvim_create_autocmd("filetype", {
      pattern = { "elixir", "eelixir", "heex" },
      callback = function()
        vim.cmd("call RagtagInit()")
        -- TODO: Does this belong here...?
        vim.cmd("source ~/.config/nvim/after/indent/heex.lua")
      end
    })
  end
}
