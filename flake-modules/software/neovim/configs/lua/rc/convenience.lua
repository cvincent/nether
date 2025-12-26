-- Easier way to leave terminal mode
vim.keymap.set("t", "<esc>", "<c-\\><c-n>")

-- Muscle memory leader stuff
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>")
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>")

vim.keymap.set("n", "<leader>a", "<cmd>A<cr>")
vim.keymap.set("n", "<leader>sa", "<cmd>AS<cr>")
vim.keymap.set("n", "<leader>va", "<cmd>AV<cr>")
vim.keymap.set("n", "<leader>Ta", "<cmd>AT<cr>")

vim.keymap.set("n", "<leader>A", "<cmd>e #<cr>")
vim.keymap.set("n", "<leader>sA", "<cmd>belowright sfind #<cr>")
vim.keymap.set("n", "<leader>vA", "<cmd>belowright vertical sfind #<cr>")
vim.keymap.set("n", "<leader>TA", "<cmd>tab sfind #<cr>")

vim.keymap.set("n", "<leader>R", "<cmd>R<cr>")
vim.keymap.set("n", "<leader>sR", "<cmd>RS<cr>")
vim.keymap.set("n", "<leader>vR", "<cmd>RV<cr>")
vim.keymap.set("n", "<leader>TR", "<cmd>RT<cr>")

vim.keymap.set("n", "<leader>s-", "<cmd>belowright Oil<cr>")
vim.keymap.set("n", "<leader>v-", "<cmd>belowright vertical Oil<cr>")
vim.keymap.set("n", "<leader>T-", "<cmd>tabnew +Oil<cr>")

-- Easy command line copy, move, and deletion by relative lines
vim.keymap.set("n", "<leader>C", ":t.<left><left>")
vim.keymap.set("n", "<leader>M", ":m.<left><left>")
vim.keymap.set("n", "<leader>D", ":d<left>")

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

-- Quick hashrocket, assign, and pipe operators
vim.keymap.set("i", "<c-l>", "<space>=><space>")
vim.keymap.set("i", "<a-l>", "<space>-><space>")
vim.keymap.set("i", "<c-e>", "<space>=<space>")
vim.keymap.set("i", "<c-i>", "|><space>")

-- Center horizontally on long lines
vim.keymap.set("n", "zh", "zszHhl")

-- Reselect visual block after indentation change
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Copy/paste
vim.keymap.set("v", "<F13>", '"+y')
-- vim.keymap.set("n", "<c-s-v>", '"+yp')

-- Ignore jumplist on { and }
-- vim.keymap.set("n", "{", ":<c-u>execute 'keepjumps norm! ' . v:count1 . '{'<cr>", { silent = true })
-- vim.keymap.set("n", "}", ":<c-u>execute 'keepjumps norm! ' . v:count1 . '}'<cr>", { silent = true })
