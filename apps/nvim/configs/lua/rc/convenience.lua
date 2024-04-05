-- Easier way to leave terminal mode
vim.keymap.set("t", "<esc>", "<c-\\><c-n>")

-- Muscle memory leader stuff
vim.keymap.set("n", "<leader>w", ":w<cr>")
vim.keymap.set("n", "<leader>q", ":q<cr>")
vim.keymap.set("n", "<leader>a", ":A<cr>")

-- Go back up the tag stack
vim.keymap.set("n", "<c-t>", ":pop<cr>")

-- Default Ctrl-C behavior isn't quite the same as Esc; fix that
vim.keymap.set("n", "<c-c>", "<esc>")

-- Alt-Del support for insert, command, and terminal modes
vim.keymap.set("i", "<m-bs>", "<c-w>")
vim.keymap.set("i", "<c-bs>", "<c-w>")
vim.keymap.set("c", "<m-bs>", "<c-w>")
vim.keymap.set("c", "<c-bs>", "<c-w>")
vim.keymap.set("t", "<c-bs>", "<a-bs>")

-- Fast ex commands
vim.keymap.set("n", "<cr>", ":")
vim.keymap.set("v", "<cr>", ":")

-- Copy to end of line with Y
vim.keymap.set("n", "Y", "y$")

-- More easily go to mark line *and* column
vim.keymap.set("n", "'", "`")
vim.keymap.set("n", "`", "'")

-- Quick hashrocket and assign operator
vim.keymap.set("i", "<c-l>", "<space>=><space>")
vim.keymap.set("i", "<c-e>", "<space>=<space>")

-- Center horizontally on long lines
vim.keymap.set("n", "zh", "zszHhl")

-- Reselect visual block after indentation change
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Navigate tabs with arrows
vim.keymap.set("n", "<right>", ":tabnext<cr>")
vim.keymap.set("n", "<left>", ":tabprev<cr>")

-- Copy/paste
vim.keymap.set("v", "<F13>", '"+y')
-- vim.keymap.set("n", "<c-s-v>", '"+yp')

-- Ignore jumplist on { and }
vim.keymap.set("n", "{", ":<c-u>execute 'keepjumps norm! ' . v:count1 . '{'<cr>", {})
vim.keymap.set("n", "}", ":<c-u>execute 'keepjumps norm! ' . v:count1 . '}'<cr>", {})
