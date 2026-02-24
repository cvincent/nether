if vim.fn.has("nvim-0.8") == 0 then
  vim.notify("This plugin requires Neovim >= 0.8", vim.log.levels.ERROR)
  return
end

-- Nothing to lazy load, this plugin just provides a function.
