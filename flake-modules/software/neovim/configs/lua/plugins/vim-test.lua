return {
  "vim-test/vim-test",

  init = function()
    vim.g["test#custom_strategies"] = {
      ["vim-test-my-tmux-strategy"] = function(cmd)
        for _ = 1, 5 do
          vim.system({
            "tmux", "send-keys", "-t",
            vim.g.vim_test_tmux_target,
            "c-c"
          }):wait()
        end

        vim.system({
          "tmux", "send-keys", "-t",
          vim.g.vim_test_tmux_target,
          cmd,
          vim.g.vim_test_args,
        }):wait()

        vim.system({
          "tmux", "send-keys", "-t",
          vim.g.vim_test_tmux_target,
          "ENTER",
        }):wait()

        -- This version prints the output in color and also saves it to a file, to maybe be later used to generate a quickfix list
        -- call system("tmux send-keys -t " . g:vim_test_tmux_target . " 'script --return --quiet -c \"" . a:cmd . "\" >&1 | tee testout' ENTER")
      end
    }

    vim.g["test#strategy"] = "vim-test-my-tmux-strategy"
    vim.g.vim_test_tmux_target = ":0.1"
    vim.g.vim_test_args = ""
    vim.g.vim_test_ff_args = ""

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "*",
      callback = function()
        vim.keymap.set("n", "<leader>tt", ":TestLast<cr>")
        vim.keymap.set("n", "<leader>tn", ":TestNearest<cr>")
        vim.keymap.set("n", "<leader>tf", ":TestFile<cr>")
        vim.keymap.set("n", "<leader>ta", ":TestSuite<cr>")
        vim.keymap.set("n", "<leader>tF", ":TestToggleFailFast<cr>")
      end,
    })

    vim.api.nvim_create_user_command("TestToggleFailFast", function()
      if vim.g.vim_test_args == "" then
        vim.g.vim_test_args = " " .. vim.g.vim_test_ff_args
      else
        vim.g.vim_test_args = ""
      end
    end, {})
  end
}
