-- This is just a function, so why a plugin? Good question. I suppose the
-- configurability, and the fact that it's dependent on another plugin?

local M = {}

local default_opts = {
  defaults = {
    layout = "right",
    winblend = 15,
  },

  tmp_result_file = ".fzf-result",
}

local config = vim.deepcopy(default_opts)

function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})
end

-- TODO: Add more layouts
--- @alias toggleterm-fzf.layout_name "right"

local layouts = {
  right = {
    direction = "float",
    border = { "│", "", "", "", "", "", "│", "│" },
    width = function()
      return math.floor(vim.o.columns * 0.3)
    end,
    col = function()
      return math.floor(vim.o.columns - vim.o.columns * 0.3)
    end,
    height = function()
      local ui = vim.api.nvim_list_uis()[1]
      return ui.height - 2
    end,
  },
}

--- @class toggleterm-fzf.Opts
--- @field cmd string
--- @field callback function
--- @field expected_keys string[]?
--- @field layout toggleterm-fzf.layout_name?
--- @field winblend integer?

--- @param opts toggleterm-fzf.Opts
function M.picker(opts)
  local layout = layouts[opts.layout or config.defaults.layout]
  local expected_keys = table.concat(opts.expected_keys or { "enter" }, ",")

  local cmd = table.concat({
    opts.cmd, "--height 100%",
    "--expect", expected_keys,
    ">", config.tmp_result_file
  }, " ")

  return require("toggleterm.terminal").Terminal:new({
    cmd = cmd,
    direction = layout.direction,
    float_opts = {
      winblend = opts.winblend or config.defaults.winblend,
      border = layout.border,
      width = layout.width,
      col = layout.col,
      height = layout.height,
    },
    on_exit = function()
      local result = vim.fn.readfile(config.tmp_result_file)
      vim.fn.delete(config.tmp_result_file)

      if result[1] then
        opts.callback(result[1], result[2])
      end
    end
  }):toggle()
end

return M
