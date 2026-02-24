if vim.fn.has("nvim-0.8") == 0 then
  vim.notify("This plugin requires Neovim >= 0.8", vim.log.levels.ERROR)
  return
end

local mod

local function get_mod()
  if not mod then
    mod = require("jj-fugitive-toggleterm")
  end
  return mod
end

local augroup = vim.api.nvim_create_augroup("jj-fugitive-toggleterm", {
  clear = true,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = "fugitive",
  callback = function() get_mod().fugitive_status_window_loaded() end,
})

vim.api.nvim_create_user_command("JJWindow", function()
  get_mod().open_global_window()
end, {})

vim.api.nvim_create_user_command("JJNewWindow", function()
  get_mod().open_jj_new_window()
end, {})
