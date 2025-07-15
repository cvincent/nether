return {
  "vim-test/vim-test",

  init = function()
    vim.api.nvim_exec([[
      function! VimTestMyTmuxStrategy(cmd)
        call system("tmux send-keys -t " . g:vim_test_tmux_target . " C-C ENTER")
        " This version prints the output in color and also saves it to a file, to maybe be later used to generate a quickfix list
        " call system("tmux send-keys -t " . g:vim_test_tmux_target . " 'script --return --quiet -c \"" . a:cmd . "\" >&1 | tee testout' ENTER")
        call system("tmux send-keys -t " . g:vim_test_tmux_target . " '" . a:cmd . "' ENTER")
      endfunction

      let g:test#custom_strategies = {'vim-test-my-tmux-strategy': function('VimTestMyTmuxStrategy')}
      let g:test#strategy = 'vim-test-my-tmux-strategy'
      let g:vim_test_tmux_target = ":0.1"
    ]], true)

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "*",
      callback = function()
        vim.keymap.set("n", "<leader>tt", ":TestLast<cr>")
        vim.keymap.set("n", "<leader>tn", ":TestNearest<cr>")
        vim.keymap.set("n", "<leader>tf", ":TestFile<cr>")
        vim.keymap.set("n", "<leader>ta", ":TestSuite<cr>")
      end,
    })
  end
}
