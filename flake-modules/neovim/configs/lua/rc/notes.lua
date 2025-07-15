local notes_root = "/backup/chris/vim-notes"

vim.api.nvim_create_user_command(
  "Note",
  function(opts)
    vim.api.nvim_command("e " .. notes_root .. "/" .. opts.args .. ".md")
    -- Use :w! to avoid annoying prompt when editing a file on Samba
    vim.keymap.set("n", "<leader>w", ":w!<cr>", { buffer = true })
  end,
  {
    nargs = 1,
    force = true,
    complete = function()
      local files = vim.api.nvim_eval("system('find " .. notes_root .. " -type f | xargs -d \"\n\" -L1 basename | cut -d. -f1')")

      local result = {}
      for line in string.gmatch(files, "[^\n]+") do
        table.insert(result, line)
      end

      return result
    end
  }
)

vim.keymap.set("n", "<leader>nn", ":Note ")

vim.keymap.set("n", "<leader>N", function()
  vim.api.nvim_command("wincmd v")
  vim.api.nvim_command("wincmd L")

  vim.api.nvim_command("vertical resize 83")
  vim.api.nvim_command("set winfixwidth")
  vim.api.nvim_command("set signcolumn=no")

  cmd = vim.api.nvim_replace_termcodes(':Note <up>', true, true, true)
  vim.api.nvim_feedkeys(cmd, "n", true)
end)
