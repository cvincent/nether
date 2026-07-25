local lazyspec = function(exports)
  return {
    "nvimtools/none-ls.nvim",

    exports = exports,

    opts = function(_, opts)
      local nls = require("null-ls")

      opts.sources = vim.list_extend(opts.sources or {}, {
        nls.builtins.diagnostics.credo.with({
          condition = function(utils)
            return utils.root_has_file(".credo.exs")
          end,
          args = {
            "credo", "suggest",
            "--format", "json",
            "--read-from-stdin",
            "--strict",
            "$FILENAME",
          },
          method = nls.methods.DIAGNOSTICS_ON_SAVE,
        }),

        {
          name = "dialyzer",
          method = nls.methods.DIAGNOSTICS_ON_SAVE,
          filetypes = { "elixir" },

          generator = nls.generator({
            format = "raw",
            multiple_files = true,
            to_stdin = false,
            from_stderr = false,

            -- Guard Dialyzer call behind a lock to prevent concurrent runs
            command = "bash",
            args = {
              "-c",
              [[
                set -euo pipefail

                LOCK_FILE=".none-ls-dialyzer.lock"

                (
                  exec 200>"$LOCK_FILE"
                  flock -n 200 || exit 0
                  output=$(MIX_OS_CONCURRENCY_LOCK=0 mix dialyzer "$@" 2>&1 >/dev/null) || true
                  printf '%s\n' "$output"
                )
              ]]
            },

            on_output = exports.from_multiline_pattern(
              "([^.]+%.exs?):(%d+):(%d+):(.-)________________________________________________________________________________\n",
              { "filename", "row", "col", "message" },
              {
                -- Transform errors at line 0 with no column into errors at line
                -- 1, column 1
                pre = function(output)
                  local ok = true
                  for file, line, err in output:gmatch("([^.\n]+%.exs?):(%d+):([^:\n]+)\n") do
                    match = file .. ":" .. line .. ":" .. err
                    if line == 0 then line = 1 end
                    ok, output = pcall(string.gsub, output, match, file .. ":" .. line .. ":1:" .. err)
                    if not ok then return "" end
                  end
                  return output
                end,
              }
            ),
          }),
        },

        {
          name = "boundary",
          method = nls.methods.DIAGNOSTICS_ON_SAVE,
          filetypes = { "elixir" },
          generator = nls.generator({
            command = "mix",
            args = { "boundary.spec" },
            env = { BOUNDARY_SPEC = "1" },
            to_stdin = false,
            from_stderr = false,
            format = "raw",
            multiple_files = true,
            on_output = exports.from_elixir_boundary_warnings(),
          }),
        }
      })
    end,
  }
end

-- gmatch's iterator is a multi-value return, so it's kind of useless if the
-- number of captures is variable. This function wraps it so each iteration
-- returns a table of captures instead.
local gmatch_captures = function(s, pattern)
  local iter = s:gmatch(pattern)
  return function()
    local t = { iter() }
    if t[1] ~= nil then
      return t
    end
  end
end

local from_multiline_pattern = function(pattern, groups, opts)
  opts = opts or {}
  local helpers = require("null-ls.helpers")

  return function(params, done)
    local output = params.output or ""
    if opts.pre then output = opts.pre(output) end

    local diagnostics = {}

    for matches in gmatch_captures(output, pattern) do
      local components = {}

      for i, g in ipairs(groups) do
        if not components[g] then
          components[g] = matches[i]
        else
          components[g] = components[g] .. "\n" .. matches[i]
        end
      end

      components.row = components.row or 1
      components.row = tonumber(components.row)
      if components.row == 0 then components.row = 1 end

      -- If opts.col_seeker is provided, pass it the line from source. It
      -- returns a list of strings to try and find in that line so we can set
      -- the column number accurately.
      if opts.col_seeker then
        local path = vim.fn.expand("%:p")

        if components.filename then
          path = vim.fn.fnamemodify(components.filename, ":p")
        end

        local ok, lines = pcall(vim.fn.readfile, path)

        if ok then
          local source_line = lines[components.row]

          if source_line then
            local col_seeks = opts.col_seeker(components.message)

            for _, seek in ipairs(col_seeks) do
              local start_col, end_col = source_line:find(seek, 1, true)

              if start_col then
                components.col = start_col
                components.end_col = end_col + 1
                break
              end
            end
          end
        end
      end

      components.col = components.col or 1
      components.col = tonumber(components.col)
      components.end_col = components.end_col or components.col + 1

      components.severity = components.severity or "warning"
      components.severity = helpers.diagnostics.severities[components.severity]

      table.insert(diagnostics, components)
    end

    done(diagnostics)
  end
end

local from_elixir_boundary_warnings = function()
  return from_multiline_pattern(
    "warning: ([^\n]+\n?[^\n]+)\n  ([^:]+):(%d+)",
    { "message", "filename", "row" },
    {
      col_seeker = function(message)
        local mod = message:match("forbidden reference to ([%w.]+)")
        mod = mod or message:match("([%w.]+) is not included in any boundary")

        if not mod then
          return {}
        else
          -- Try to find the fully qualified module name first, followed by
          -- successive shorter aliases.
          local parts = {}
          for part in mod:gmatch("[^.]+") do
            table.insert(parts, part)
          end

          local result = {}
          for i = 1, #parts do
            table.insert(result, table.concat(parts, ".", i))
          end
          return result
        end
      end,
    }
  )
end

return lazyspec({
  from_multiline_pattern = from_multiline_pattern,
  from_elixir_boundary_warnings = from_elixir_boundary_warnings,
})
