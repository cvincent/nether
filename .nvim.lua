vim.g.per_project = {
  tmux_default_target = "dotfiles:1.2",
  nvr_pipe = "/tmp/nvim-dotfiles",
}

vim.api.nvim_create_autocmd("User", {
  pattern = "JJFugitiveToggletermFugitiveStatusLoaded",
  callback = function(ev)
    local picker = ev.data.picker
    local run = ev.data.run
    local jj_cmd = ev.data.jj_cmd

    vim.keymap.set("n", "<leader>jb", function()
      vim.api.nvim_command("wincmd q")

      picker({
        cmd = NixToNvim.jj.fzf_bookmarks,
        callback = function(_, bookmark)
          run(jj_cmd("split", "-B " .. bookmark))
        end,
      })
    end, { buffer = true })
  end,
})
