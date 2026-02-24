-- Jumplist behaves like a stack, and remembers scroll position
vim.opt.jumpoptions = { "stack", "view" }

-- Jumping by relative lines is added to the jumplist over a certain distance
local jump_with_jumplist_threshold = function(key)
  return function()
    if vim.v.count > 10 then
      vim.cmd("norm! m'" .. vim.v.count .. key)
    else
      vim.cmd("norm! " .. vim.v.count .. key)
    end
  end
end

vim.keymap.set("n", "j", jump_with_jumplist_threshold("j"))
vim.keymap.set("n", "k", jump_with_jumplist_threshold("k"))

-- Ignore jumplist on { and }
-- vim.keymap.set("n", "{", ":<c-u>execute 'keepjumps norm! ' . v:count1 . '{'<cr>", { silent = true })
-- vim.keymap.set("n", "}", ":<c-u>execute 'keepjumps norm! ' . v:count1 . '}'<cr>", { silent = true })
