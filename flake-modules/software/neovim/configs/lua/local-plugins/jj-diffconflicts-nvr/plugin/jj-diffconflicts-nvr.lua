-- This file loads automatically at boot if the plugin is enabled. It should do
-- as little as possible to set up its mechanisms for lazy loading. In this
-- case, we define the main user command which lazily loads the plugin the first
-- time it is called.

-- Supposedly you can define a lazy.lua file to provide explicit lazy loading
-- directives for Lazy.nvim, but I was not able to get this to work.

if vim.fn.has("nvim-0.8") == 0 then
  vim.notify("This plugin requires Neovim >= 0.8", vim.log.levels.ERROR)
  return
end

local mod

local function get_mod()
  if not mod then
    mod = require("jj-diffconflicts-nvr")
  end
  return mod
end

vim.api.nvim_create_user_command("JJDiffconflictsNvr", function(cmd)
  get_mod().commence(cmd)
end, {
  nargs = "+",
})
