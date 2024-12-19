require("helpers")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })

  if vim.v .. shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." }
    }, true, {})
  end
end
vim.opt.rtp:prepend(lazypath)

-- Space as leader; apparently needs to be set before Lazy init
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("lazy").setup("plugins", {
  change_detection = { notify = false },
})

if IsPluginInstalled("oil.nvim") then
  -- This is unorthodox, but for some reason you have to explicitly require
  -- oil.nvim, along with its opts. Maybe ask them to fix this.
  require("oil").setup({
    keymaps = {
      ["<C-l>"] = false,
      ["<C-h>"] = false,
    },
  })
end

require("rc")
