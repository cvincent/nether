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
  end
}
