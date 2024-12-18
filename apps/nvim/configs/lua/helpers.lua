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
