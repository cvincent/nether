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

    if IsPluginInstalled("toggleterm.nvim") and IsPluginInstalled("vim-test") then
      local jj_picker = require('toggleterm.terminal').Terminal:new({
        cmd = NixToNvim.jj.fzf_commit_ids .. " jj --height=100% --expect=ctrl-a,ctrl-b " .. " > .fzf-result",
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
          vim.g.toggleterm_fzf_callback()
        end
      }) --:toggle()

      local jj_cmd = function(subcmd, rest)
        -- Need to call this as a function so we're sure vim.g.nvr_pipe is set
        -- from the local .nvim.lua.
        local editor = "nvr --servername " .. vim.g.nvr_pipe .. " -cc \":lua QuickFloatingEdit()\" --remote-wait"
        return "EDITOR='" .. editor .. "' jj " .. subcmd .. " --tool git-index " .. rest
      end

      local jj_positional = function(subcmd)
        return function()
          local key = vim.g.toggleterm_fzf_result[1]
          local change = vim.g.toggleterm_fzf_result[2]

          if key == "" or key == "ctrl-a" then
            TmuxTestPaneExec(jj_cmd(subcmd, "-A " .. change))
          elseif key == "ctrl-b" then
            TmuxTestPaneExec(jj_cmd(subcmd, "-B " .. change))
          end
        end
      end

      local jj_squash = function()
        local key = vim.g.toggleterm_fzf_result[1]
        local change = vim.g.toggleterm_fzf_result[2]
        TmuxTestPaneExec(jj_cmd("squash", "-t " .. change))
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "fugitive",
        callback = function()
          vim.keymap.set("n", "<leader>jp", function()
            vim.api.nvim_command("wincmd q")
            vim.g.toggleterm_fzf_callback = jj_positional("split")
            jj_picker:toggle()
          end, { buffer = true })

          -- Probably need to think about this one still
          vim.keymap.set("n", "<leader>jr", function()
            vim.api.nvim_command("wincmd q")
            vim.g.toggleterm_fzf_callback = jj_positional("rebase")
            jj_picker:toggle()
          end, { buffer = true })

          vim.keymap.set("n", "<leader>jq", function()
            vim.api.nvim_command("wincmd q")
            vim.g.toggleterm_fzf_callback = jj_squash
            jj_picker:toggle()
          end, { buffer = true })
        end,
      })
    end
  end
}
