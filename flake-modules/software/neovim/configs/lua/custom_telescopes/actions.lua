local M = {}

M.find_existing_window = function(prompt_bufnr)
  -- Open existing window for buffer if there is one, otherwise
  -- perform the default behavior (open buffer in current window)
  local action_state = require("telescope.actions.state")
  local actions = require("telescope.actions")
  local entry = action_state.get_selected_entry()

  local winid = vim.fn.win_findbuf(entry.bufnr)

  if #winid > 0 then
    vim.fn.win_gotoid(winid[1])
    vim.fn.execute(':' .. entry.lnum)
  else
    actions.select_default(prompt_bufnr)
  end
end

return M
