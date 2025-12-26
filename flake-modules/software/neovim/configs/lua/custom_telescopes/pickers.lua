local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local sorters = require("telescope.sorters")
local config = require("telescope.config").values

local M = {}

M.tmux_files = function(opts)
  opts = opts or {}

  local command = "tmux list-panes -F '#{pane_id}' | " ..
      "xargs -I {} tmux capture-pane -Jpt {} | " ..
      "grep -Eio '(^| )[^/][a-z0-9/_.-]+[a-z][a-z0-9/_.-]+:[0-9]+' | " ..
      "sed 's/^[[:space:]]*//' | " ..
      [[sed 's/^\.\///' | ]] ..
      "sort | " ..
      "uniq"

  local finder = finders.new_dynamic(
    {
      fn = function()
        local handle = io.popen(command)

        if handle == nil then
          return {}
        end

        local output = handle:read("*a")
        handle:close()
        return vim.split(output, "\n")
      end,

      -- TODO: set bufnr; and I think that's it?
      entry_maker = function(line)
        local split = vim.split(line, ":")
        local bufnr = vim.fn.bufnr(split[1])

        return {
          value = line,
          ordinal = line,
          display = line,
          filename = split[1],
          lnum = tonumber(split[2]),
          bufnr = (bufnr > -1 and { bufnr } or { nil })[1],
        }
      end,
    }
  )

  pickers.new(opts, {
    prompt_title = "Files from tmux",
    finder = finder,
    previewer = config.grep_previewer(opts),
    sorter = sorters.get_generic_fuzzy_sorter(opts),
    attach_mappings = function(_, map)
      map("i", "<cr>", require("custom_telescopes.actions").find_existing_window)
      return true
    end
  }):find()
end

return M
