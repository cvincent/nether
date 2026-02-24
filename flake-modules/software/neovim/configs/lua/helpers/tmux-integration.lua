local M = {}

--- @param cmds elem_or_list
local send_keys_and_enter = function(cmds)
  vim.system(vim.list_extend(
    {
      "tmux", "send-keys", "-t",
      vim.g.per_project.tmux_default_target,
      cmd, "ENTER",
    },
    vim.iter({ cmds, "ENTER" }):flatten():totable()
  )):wait()
end

--- @param cmds elem_or_list
M.tmux_exec = function(cmds)
  send_keys_and_enter({ "C-c", "C-c" })
  send_keys_and_enter(cmds)
end

return M
