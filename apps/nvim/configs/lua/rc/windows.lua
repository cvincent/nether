-- Keep splits equal
vim.opt.equalalways = true
vim.api.nvim_create_autocmd("VimResized", { command = "wincmd =" })

-- More natural split directions
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Easy split navigation
vim.keymap.set("n", "<c-h>", "<c-w>h", { silent = true, remap = true })
vim.keymap.set("n", "<c-j>", "<c-w>j", { silent = true, remap = true })
vim.keymap.set("n", "<c-k>", "<c-w>k", { silent = true, remap = true })
vim.keymap.set("n", "<c-l>", "<c-w>l", { silent = true, remap = true })

-- Tab navigation
vim.keymap.set("n", "<c-a-left>", ":tabp<cr>")
vim.keymap.set("i", "<c-a-left>", "<esc>:tabp<cr>i")
vim.keymap.set("n", "<c-a-right>", ":tabn<cr>")
vim.keymap.set("i", "<c-a-right>", "<esc>:tabn<cr>i")

-- Wrap split navigation
local function go_to_next_window(direction, count)
  prev_winnr = vim.api.nvim_eval("winnr()")
  vim.api.nvim_command(count .. "wincmd " .. direction)
  return not (vim.api.nvim_eval("winnr()") == prev_winnr)
end

local function jump_with_wrap(direction, opposite)
  if not go_to_next_window(direction, 1) then
    go_to_next_window(opposite, 99)
  end
end

vim.keymap.set("n", "<c-w>h", function() jump_with_wrap("h", "l") end, { silent = true })
vim.keymap.set("n", "<c-w>j", function() jump_with_wrap("j", "k") end, { silent = true })
vim.keymap.set("n", "<c-w>k", function() jump_with_wrap("k", "j") end, { silent = true })
vim.keymap.set("n", "<c-w>l", function() jump_with_wrap("l", "h") end, { silent = true })
