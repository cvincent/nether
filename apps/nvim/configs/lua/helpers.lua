function IsPluginInstalled(plugin)
  local plugin = require("lazy.core.config").plugins[plugin]
  return plugin and plugin._.installed
end
