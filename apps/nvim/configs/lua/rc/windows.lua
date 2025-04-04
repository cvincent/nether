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

-- Focus floating window, if any
function _G.focus_floating()
  local wins = vim.api.nvim_list_wins()
  for _, win in ipairs(wins) do
    if vim.api.nvim_win_get_config(win).relative == "editor" then
      vim.api.nvim_set_current_win(win)
      break
    end
  end
end

vim.keymap.set("n", "<c-space>", focus_floating, {})

-- Wrap split navigation
local function go_to_next_window(direction, count)
  local prev_winnr = vim.api.nvim_eval("winnr()")
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

-- Alt-t to open a new tab
vim.keymap.set("n", "<a-t>", ":tabnew<cr>")

-- Navigate tabs with arrows
vim.keymap.set("n", "<right>", ":tabnext<cr>")
vim.keymap.set("n", "<left>", ":tabprev<cr>")

-- Move tabs with ctrl-arrows
vim.keymap.set("n", "<c-right>", ":tabmove +1<cr>")
vim.keymap.set("n", "<c-left>", ":tabmove -1<cr>")

-- Go to previous tab when closing a tab
local tabs_navigation_augroup = vim.api.nvim_create_augroup("tabs.navigation", {})
vim.api.nvim_create_autocmd("TabClosed", {
  group = tabs_navigation_augroup,
  callback = function()
    vim.cmd("tabprevious")
  end
})
