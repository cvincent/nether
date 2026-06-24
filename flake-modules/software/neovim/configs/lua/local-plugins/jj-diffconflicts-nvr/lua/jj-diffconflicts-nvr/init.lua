local M = {}

-- If we had other modules, we'd use them like this:
-- local other_mod = require("jj-diffconflicts-nvr.other_mod")
-- M.other_mod_exported = other_mod.export_me;

local default_opts = {
  conflict_loaded = function() end,
}

local config = vim.deepcopy(default_opts)

-- Setup is called automatically if options are provided in the user plugin
-- spec. This should not do any requires or much at all other than override
-- default config options.

function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})
end

-- This is about as close as we get to ADTs in Lua.
-- See: https://mrcjkb.dev/posts/2023-08-17-lua-adts.html

--- @class StateUninitialized
--- @field uninitialized boolean

--- @class StateInitialized
--- @field initialized boolean

--- @class StateActive
--- @field starting_tab_id number
--- @field diff_tab_id number
--- @field history_tab_id number

--- @alias State StateUninitialized | StateInitialized | StateActive

--- @type State
local state = {
  uninitialized = true,
}

--- @alias command_args vim.api.keyset.create_user_command.command_args

--- @param cmd command_args
function M.commence(cmd)
  local starting_tab_id = vim.api.nvim_get_current_tabpage()
  vim.g.jj_diffconflicts_marker_length = tonumber(cmd.fargs[1])

  vim.cmd("tabnew")
  local history_tab_id = vim.api.nvim_get_current_tabpage()
  M.setup_history_buffer("e", cmd.fargs[2])
  M.setup_history_buffer("vsplit", cmd.fargs[3])
  M.setup_history_buffer("vsplit", cmd.fargs[4])

  -- The jj merge-tool config is going to open the actual diff file for us, so
  -- we prepare the tab and set a one-shot autocmd to set it up.

  vim.cmd("-tabnew")
  local diff_tab_id = vim.api.nvim_get_current_tabpage()

  -- Most of the time plugins should use either <Plug> keymaps or user commands
  -- which users can map themselves. Situational buffer-local mappings are one
  -- exception to this rule.

  -- However in this case I'll define a user command for concluding the resolve
  -- session which they can map, and also a callback for when the conflict diff
  -- buffer is opened so they can do whatever they need to do, such as override
  -- their custom keymaps they don't want interfering.

  vim.api.nvim_create_autocmd("BufWinEnter", {
    once = true,
    pattern = cmd.fargs[5],
    callback = function()
      config.conflict_loaded()
      vim.cmd("JJDiffConflicts")
    end,
  })

  if state.uninitialized then
    vim.api.nvim_create_user_command("JJDiffConflictsNvrConclude", M.conclude, {})
  end

  state = {
    starting_tab_id = starting_tab_id,
    diff_tab_id = diff_tab_id,
    history_tab_id = history_tab_id,
  }
end

--- @param open_with string
--- @param path string
function M.setup_history_buffer(open_with, path)
  vim.cmd(open_with .. " " .. path)
  vim.cmd("diffthis")
end

--- @param _ command_args
function M.conclude(_)
  local history_open, history_tabnr = pcall(
    vim.api.nvim_tabpage_get_number, state.history_tab_id
  )

  local diff_open, diff_tabnr = pcall(
    vim.api.nvim_tabpage_get_number, state.diff_tab_id
  )

  -- We expect this to be called from a buffer-local mapping set by the user,
  -- so we must be already looking at the diff window.
  vim.cmd("bd!")
  local _ = history_open and vim.cmd(history_tabnr .. "tabclose")
  local _ = diff_open and vim.cmd(diff_tabnr .. "tabclose")

  pcall(vim.api.nvim_set_current_tabpage, state.starting_tab_id)

  state = { initialized = true, }
end

return M
