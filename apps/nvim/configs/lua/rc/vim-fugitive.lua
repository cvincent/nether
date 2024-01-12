local function CurrentBranch()
  local branch = vim.api.nvim_eval("system('git branch --show-current')")
  return branch:match("^%s*(.-)%s*$")
end

local function PullFromCurrentBranch()
  local branch = CurrentBranch()
  vim.api.nvim_command("Git pull origin " .. branch)
end

local function PushToCurrentBranch()
  local branch = CurrentBranch()
  vim.api.nvim_command("Git push origin " .. branch)
end

vim.keymap.set("n", "<leader>gpl", function() PullFromCurrentBranch() end)
vim.keymap.set("n", "<leader>gpu", function() PushToCurrentBranch() end)

vim.keymap.set("n", "<leader>gs", ":Git<cr>)", { silent = true })
vim.keymap.set("n", "<leader>gd", ":tab Gdiff<cr>", { silent = true })
-- vim.keymap.set("n", "<leader>gc", ":Git checkout ")
vim.keymap.set("n", "<leader>gb", ":Git checkout -b ")
vim.keymap.set("n", "<leader>gm", ":Git merge ")

-- Don't use terminal emulator for git output
_G.fugitive_force_bang_command = 1

vim.api.nvim_create_autocmd("FileType", {
  pattern = "gitcommit",
  command = "nmap <buffer> <leader>w :wq<cr>"
})
