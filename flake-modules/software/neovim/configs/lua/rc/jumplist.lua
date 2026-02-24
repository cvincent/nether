-- Jumplist behaves like a stack, and remembers scroll position
vim.opt.jumpoptions = { "stack", "view" }

-- Ignore jumplist on { and }
-- vim.keymap.set("n", "{", ":<c-u>execute 'keepjumps norm! ' . v:count1 . '{'<cr>", { silent = true })
-- vim.keymap.set("n", "}", ":<c-u>execute 'keepjumps norm! ' . v:count1 . '}'<cr>", { silent = true })
