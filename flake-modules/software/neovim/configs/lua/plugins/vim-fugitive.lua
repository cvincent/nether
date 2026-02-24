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
    local tmux_exec = require("helpers.tmux-integration").tmux_exec_with_remote_editor
    local picker = require("toggleterm-fzf").picker

    if IsPluginInstalled("toggleterm.nvim") and IsPluginInstalled("vim-test") then
      local jj_cmd = function(subcmd, rest)
        return "jj " .. subcmd .. " --tool git-index " .. rest .. "; jj --no-pager"
      end

      local other_cmd = function(cmd, rest)
        return cmd .. " " .. rest .. " --tool git-index; jj --no-pager"
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "fugitive",
        callback = function()
          vim.keymap.set("n", "<leader>J", function()
            tmux_exec("jj")
          end, { buffer = true })

          vim.keymap.set("n", "<leader>js", function()
            vim.api.nvim_command("wincmd q")

            picker({
              cmd = NixToNvim.jj.fzf_change_ids,
              expected_keys = { "enter", "ctrl-a", "ctrl-b", "ctrl-d" },
              callback = function(key, change_id)
                if key == "" or key == "enter" or key == "ctrl-a" then
                  tmux_exec(jj_cmd("split", "-A " .. change_id))
                elseif key == "ctrl-b" then
                  tmux_exec(jj_cmd("split", "-B " .. change_id))
                elseif key == "ctrl-d" then
                  tmux_exec(jj_cmd("split", "-d " .. change_id))
                end
              end,
            })
          end, { buffer = true })

          vim.keymap.set("n", "<leader>jS", function()
            vim.api.nvim_command("wincmd q")
            tmux_exec(jj_cmd("stack_split", ""))
          end, { buffer = true })

          vim.keymap.set("n", "<leader>ja", function()
            vim.api.nvim_command("wincmd q")
            tmux_exec(other_cmd(NixToNvim.jj.split_to_absorb, ""))
          end, { buffer = true })

          vim.keymap.set("n", "<leader>jb", function()
            vim.api.nvim_command("wincmd q")

            picker({
              cmd = NixToNvim.jj.fzf_bookmarks,
              callback = function(_, bookmark)
                tmux_exec(other_cmd(NixToNvim.jj.split_to_bookmark .. " split", bookmark))
              end,
            })
          end, { buffer = true })

          vim.keymap.set("n", "<leader>jB", function()
            vim.api.nvim_command("wincmd q")
            local bookmark = vim.fn.input("New bookmark: ")
            tmux_exec(other_cmd(NixToNvim.jj.split_to_bookmark .. " stack_split", bookmark))
          end, { buffer = true })

          vim.keymap.set("n", "<leader>jq", function()
            vim.api.nvim_command("wincmd q")

            picker({
              cmd = NixToNvim.jj.fzf_change_ids,
              callback = function(_, change_id)
                tmux_exec(jj_cmd("squash", "-t " .. change_id))
              end,
            })
          end, { buffer = true })
        end,
      })
    end
  end
}
