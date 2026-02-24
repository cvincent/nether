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

--- @param env { [string]: string }
M.build_tmux_exec_func = function(env)
  local env_vars = vim.iter(env):map(function(k, v)
    return k .. "='" .. v .. "'"
  end):join(" ") .. " "

  return function(cmds)
    M.tmux_exec({ env_vars, cmds })
  end
end

local tmux_exec_with_remote_editor_func = nil

--- @param cmds elem_or_list
M.tmux_exec_with_remote_editor = function(cmds)
  if not tmux_exec_with_remote_editor_func then
    tmux_exec_with_remote_editor_func = M.build_tmux_exec_func({
      NVIM_SERVER = NvrPipe,
      EDITOR = NixToNvim.neovim.nvr_floating_edit .. " " .. NvrPipe,
    })
  end

  tmux_exec_with_remote_editor_func(cmds)
end

return M
