function IsPluginInstalled(plugin)
  local plugin = require("lazy.core.config").plugins[plugin]
  return plugin and plugin._.installed
end

function DisableFormatOnWrite(pattern)
  vim.api.nvim_create_autocmd("LspAttach", {
    pattern = pattern,
    callback = function()
      vim.api.nvim_del_augroup_by_name("lsp-format-on-write")
    end,
  })
end

IconsPlugin = "nvim-tree/nvim-web-devicons"

function CallPlugMapping(name)
  local t = function(keycode) return vim.api.nvim_replace_termcodes(keycode, true, false, true) end
  vim.api.nvim_feedkeys(t "<Plug>" .. name, "v", true)
end

NixToNvim = dofile(vim.fn.fnamemodify(vim.fn.stdpath("config"), ":h") .. "/nix-to-nvim.lua")

function TmuxTestPaneExec(cmd)
  vim.system({
    "tmux", "send-keys", "-t",
    vim.g.vim_test_tmux_target,
    "C-c", "C-c",
  }):wait()

  vim.system({
    "tmux", "send-keys", "-t",
    vim.g.vim_test_tmux_target,
    cmd, "ENTER",
  }):wait()
end
