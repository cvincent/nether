-- This is a local plugin because it may become more stateful, and because it
-- has dependencies on other plugins. The `command_runner` and `picker` options
-- are somewhat of a step towards making it usable by others (though the default
-- picker is from one of our assumed dependencies). However, there's still a lot
-- another user would need to set up in their environment to make this work with
-- their configuration:

-- - The git-index merge-tool.
-- - The command_runner would need to set the EDITOR with nvr and an equivalent
--   to :RemoteFloatingEdit to edit change descriptions in the same NeoVim
--   instance.
-- - Our custom jj stack_split alias.
-- - Our custom jj-split-to-absorb and jj-split-to-bookmark commands, which
--   currently come from the NixToNvim global.

-- So it would be quite a lot. For myself, I would like to get all of these
-- dependencies grouped into a single Nix module, when I eventually transition
-- to one of the Nix NeoVim wrappers.

local M = {}

local default_opts = {
  -- User must provide a command runner.
  command_runner = function(_) end,
  picker = require("toggleterm-fzf").picker,
}

local config = vim.deepcopy(default_opts)
local run
local picker

local set_vars_from_config = function()
  run = config.command_runner
  picker = config.picker
end

set_vars_from_config()

local jj_cmd = function(subcmd, rest)
  return "jj " .. subcmd .. " --tool git-index " .. rest .. "; jj --no-pager"
end

local jj_cmd_toolless = function(subcmd, rest)
  return "jj " .. subcmd .. " " .. rest .. "; jj --no-pager"
end

local other_cmd = function(cmd, rest)
  return cmd .. " " .. rest .. " --tool git-index; jj --no-pager"
end

function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})
  set_vars_from_config()
end

function M.fugitive_status_window_loaded()
  vim.keymap.set("n", "<leader>J", function()
    run("jj")
  end, { buffer = true })

  vim.keymap.set("n", "<leader>js", function()
    vim.api.nvim_command("wincmd q")

    picker({
      cmd = NixToNvim.jj.fzf_change_ids,
      expected_keys = { "enter", "ctrl-a", "ctrl-b", "ctrl-d" },
      callback = function(key, change_id)
        if key == "" or key == "enter" or key == "ctrl-a" then
          run(jj_cmd("split", "-A " .. change_id))
        elseif key == "ctrl-b" then
          run(jj_cmd("split", "-B " .. change_id))
        elseif key == "ctrl-d" then
          run(jj_cmd("split", "-d " .. change_id))
        end
      end,
    })
  end, { buffer = true })

  vim.keymap.set("n", "<leader>jS", function()
    vim.api.nvim_command("wincmd q")
    run(jj_cmd("stack_split", ""))
  end, { buffer = true })

  vim.keymap.set("n", "<leader>ja", function()
    vim.api.nvim_command("wincmd q")
    run(other_cmd(NixToNvim.jj.split_to_absorb, ""))
  end, { buffer = true })

  vim.keymap.set("n", "<leader>jA", function()
    vim.api.nvim_command("wincmd q")

    local width = math.floor(vim.o.columns * 0.3)
    local win_height = vim.api.nvim_list_uis()[1].height

    require("toggleterm.terminal").Terminal:new({
      cmd = "jj arrange",
      direction = "float",
      float_opts = {
        winblend = vim.o.winblend,
        border = "curved",
        width = width,
        col = width,
        height = math.floor(win_height * 0.66),
        row = math.floor(win_height * 0.33 / 2),
      },
    }):toggle()
  end, { buffer = true })

  vim.keymap.set("n", "<leader>jb", function()
    vim.api.nvim_command("wincmd q")

    picker({
      cmd = NixToNvim.jj.fzf_bookmarks,
      callback = function(_, bookmark)
        run(other_cmd(NixToNvim.jj.split_to_bookmark .. " split", bookmark))
      end,
    })
  end, { buffer = true })

  vim.keymap.set("n", "<leader>jB", function()
    vim.api.nvim_command("wincmd q")
    local bookmark = vim.fn.input("New bookmark: ")
    run(other_cmd(NixToNvim.jj.split_to_bookmark .. " stack_split", bookmark))
  end, { buffer = true })

  vim.keymap.set("n", "<leader>jq", function()
    vim.api.nvim_command("wincmd q")

    picker({
      cmd = NixToNvim.jj.fzf_change_ids,
      callback = function(_, change_id)
        run(jj_cmd("squash", "-t " .. change_id))
      end,
    })
  end, { buffer = true })
end

function M.open_global_window()
  picker({
    cmd = NixToNvim.jj.fzf_change_ids,

    expected_keys = {
      "enter",
      "ctrl-e",
      "ctrl-r",
      "ctrl-d",
      "ctrl-u",
      "ctrl-alt-u",
      "ctrl-b",
    },

    callback = function(key, change_id)
      if key == "" or key == "enter" then
        run(jj_cmd_toolless("edit", change_id))
      elseif key == "ctrl-e" then
        run(jj_cmd_toolless("diffedit", "-r " .. change_id))
      elseif key == "ctrl-r" then
        run(jj_cmd_toolless("resolve", "-r " .. change_id))
      elseif key == "ctrl-d" then
        run(jj_cmd_toolless("describe", change_id))
      elseif key == "ctrl-u" then
        run(jj_cmd_toolless("undo", ""))
      elseif key == "ctrl-alt-u" then
        run(jj_cmd_toolless("redo", ""))
      elseif key == "ctrl-b" then
        local bookmark = vim.fn.input("New bookmark: ")
        run(jj_cmd_toolless("bookmark create " .. bookmark, "-r " .. change_id))
      end
    end,
  })
end

return M
