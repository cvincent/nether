return {
  "tpope/vim-fugitive",

  init = function()
    local function current_branch()
      local branch = vim.api.nvim_eval("system('git branch --show-current')")
      return branch:match("^%s*(.-)%s*$")
    end

    local function pull_from_current_branch()
      local branch = current_branch()
      vim.api.nvim_command("Git pull origin " .. branch)
    end

    local function push_to_current_branch()
      local branch = current_branch()
      vim.api.nvim_command("Git push origin " .. branch)
    end

    local function floating_summary()
      local ui = vim.api.nvim_list_uis()[1]

      local summary = vim.fn.bufadd(".git/index")

      vim.api.nvim_open_win(summary, true, {
        relative = "editor",
        row = ui.height - (ui.height * 0.33),
        col = 0,
        width = ui.width,
        height = math.floor(ui.height * 0.33),
        border = { "", "―", "", "", "", "", "", "" },
      })

      vim.api.nvim_command("set winblend=15")
      vim.api.nvim_command("normal )")

      vim.keymap.set("n", "<c-=>", "40<c-w>+", { buffer = true })
      vim.keymap.set("n", "<c-->", "40<c-w>-", { buffer = true })
      vim.keymap.set("n", "<leader>q", ":bd<cr>", { buffer = true, silent = true, })
    end

    vim.keymap.set("n", "<leader>gpl", function() pull_from_current_branch() end)
    vim.keymap.set("n", "<leader>gpu", function() push_to_current_branch() end)

    vim.keymap.set("n", "<leader>gs", floating_summary, { silent = true })
    vim.keymap.set("n", "<leader>gd", ":tab Gdiff<cr>", { silent = true })
    vim.keymap.set("n", "<leader>gb", ":Git checkout -b ")

    -- Don't use terminal emulator for git output
    _G.fugitive_force_bang_command = 1

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "gitcommit",
      callback = function(ev)
        local wins = vim.api.nvim_list_wins()
        for _, win in ipairs(wins) do
          if vim.api.nvim_win_get_config(win).relative == "editor" then
            vim.api.nvim_win_set_buf(win, ev.buf)
            vim.api.nvim_win_hide(0)
            vim.api.nvim_set_current_win(win)
            vim.api.nvim_command("startinsert")
            break
          end
        end

        vim.keymap.set("n", "<leader>w", ":wq<cr>", { buffer = true })
      end,
    })

    -- TODO: This is an awesome mess lol.
    local tmux_exec = require("helpers.tmux-integration").tmux_exec

    if IsPluginInstalled("toggleterm.nvim") and IsPluginInstalled("vim-test") then
      -- TODO: We are here. We need an fzf picker for bookmarks, then to bind
      -- <leader>jb to our new `jj-split-to-bookmark` command.

      local jj_picker = function(fzf_cmd)
        return require('toggleterm.terminal').Terminal:new({
          cmd = fzf_cmd .. " --height 100% > .fzf-result",
          direction = "float",
          float_opts = {
            winblend = 15,
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
          on_exit = function()
            vim.g.toggleterm_fzf_result = vim.fn.readfile(".fzf-result")
            vim.fn.delete(".fzf-result")

            if vim.g.toggleterm_fzf_callback then
              vim.g.toggleterm_fzf_callback()
            end
          end
        })
      end

      local jj_change_id_picker = jj_picker(
        NixToNvim.jj.fzf_commit_ids .. " jj --expect=ctrl-a,ctrl-b,ctrl-d"
      )

      local jj_bookmark_picker = jj_picker(
        NixToNvim.jj.fzf_commit_ids .. " 'jj bookmark' --expect=enter"
      )

      local jj_editor = function()
        -- Need to call this as a function so we're sure vim.g.nvr_pipe is set
        -- from the local .nvim.lua.

        -- TODO: Probably wrap this editor in a command so our fish history
        -- isn't so bad for it.
        return "NVIM_SERVER=" .. vim.g.per_project.nvr_pipe .. " EDITOR='nvr --servername " ..
            vim.g.per_project.nvr_pipe .. " -cc \":lua QuickFloatingEdit()\" --remote-wait' "
      end

      local jj_cmd = function(subcmd, rest)
        return jj_editor() .. " jj " .. subcmd .. " --tool git-index " .. rest .. "; jj --no-pager"
      end

      local other_cmd = function(cmd, rest)
        return jj_editor() .. cmd .. " " .. rest .. " --tool git-index; jj --no-pager"
      end

      local callback_jj_positional = function(subcmd)
        return function()
          local key = vim.g.toggleterm_fzf_result[1]
          local change = vim.g.toggleterm_fzf_result[2]

          if key == "" or key == "ctrl-a" then
            tmux_exec(jj_cmd(subcmd, "-A " .. change))
          elseif key == "ctrl-b" then
            tmux_exec(jj_cmd(subcmd, "-B " .. change))
          elseif key == "ctrl-d" then
            tmux_exec(jj_cmd(subcmd, "-d " .. change))
          end
        end
      end

      local callback_jj_to_target = function(subcmd)
        return function()
          local change = vim.g.toggleterm_fzf_result[2]
          if change then
            tmux_exec(jj_cmd(subcmd, "-t " .. change))
          end
        end
      end

      local callback_other_cmd = function(cmd)
        return function()
          local bookmark = vim.g.toggleterm_fzf_result[2]
          if bookmark then
            tmux_exec(other_cmd(cmd, bookmark))
          end
        end
      end

      local jj_no_picker = function(subcmd)
        tmux_exec(jj_cmd(subcmd, ""))
      end

      local other_cmd_no_picker = function(subcmd)
        tmux_exec(other_cmd(subcmd, ""))
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "fugitive",
        callback = function()
          vim.keymap.set("n", "<leader>J", function()
            tmux_exec("jj")
          end, { buffer = true })

          vim.keymap.set("n", "<leader>js", function()
            vim.api.nvim_command("wincmd q")
            vim.g.toggleterm_fzf_callback = callback_jj_positional("split")
            jj_change_id_picker:toggle()
          end, { buffer = true })

          vim.keymap.set("n", "<leader>jS", function()
            vim.api.nvim_command("wincmd q")
            jj_no_picker("stack_split")
          end, { buffer = true })

          vim.keymap.set("n", "<leader>ja", function()
            vim.api.nvim_command("wincmd q")
            other_cmd_no_picker(NixToNvim.jj.split_to_absorb)
          end, { buffer = true })

          vim.keymap.set("n", "<leader>jb", function()
            vim.api.nvim_command("wincmd q")
            vim.g.toggleterm_fzf_callback = callback_other_cmd(
              NixToNvim.jj.split_to_bookmark
            )
            jj_bookmark_picker:toggle()
          end, { buffer = true })

          -- Probably need to think about this one still
          vim.keymap.set("n", "<leader>jr", function()
            vim.api.nvim_command("wincmd q")
            vim.g.toggleterm_fzf_callback = callback_jj_positional("rebase")
            jj_change_id_picker:toggle()
          end, { buffer = true })

          vim.keymap.set("n", "<leader>jq", function()
            vim.api.nvim_command("wincmd q")
            vim.g.toggleterm_fzf_callback = callback_jj_to_target("squash")
            jj_change_id_picker:toggle()
          end, { buffer = true })
        end,
      })
    end
  end
}
