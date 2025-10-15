-- Restore default behavior for gg etc
vim.opt.startofline = true

-- Advanced blending
vim.opt.termguicolors = true
vim.opt.pumblend = 15
vim.opt.winblend = 15

-- Nice, long ex command history
vim.opt.history = 10000

-- Match angle brackets
vim.opt.matchpairs = vim.opt.matchpairs + "<:>"

-- Maybe learn what these do before fucking with them :P
-- set wildmenu
-- set wildmode=full
-- set completeopt=menuone,preview
-- set infercase

-- Ignore case during ex file completion
vim.opt.wildignorecase = true

-- Smartcase for search commands
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Set terminal window title to root directory of project
vim.opt.title = true
vim.opt.titlestring = "nvim: %(%{fnamemodify(getcwd(), ':t')}%)"

-- Minimum 3 lines from vertical edges
vim.opt.scrolloff = 3

-- Looking at the :help for these, might be best to leave them be
-- set directory=/tmp/
-- set nobackup
-- set nowritebackup
-- set noswapfile
vim.opt.swapfile = false

-- Show bad whitespace
vim.opt.list = true
vim.opt.listchars = "tab:>-,trail:·,nbsp:+"

-- Shorten various Vim messages
vim.opt.shortmess = "atIOc"

-- Persistent undo
vim.opt.undofile = true

-- Include winfixwidth in sessions
vim.opt.sessionoptions:append("resize")
vim.opt.sessionoptions:remove("folds")
vim.opt.sessionoptions:remove("buffers")

-- Per-project .vimrc files; safe commands only
vim.opt.exrc = true
vim.opt.secure = true

-- Search/replace all matches on a line by default
vim.opt.gdefault = true

-- Don't wrap long lines by default
vim.opt.wrap = false

-- But do automatically hard-wrap comments
vim.opt.formatoptions:append("c") -- Autowrap comments
vim.opt.formatoptions:remove("t") -- Do not autowrap other text
vim.opt.textwidth = 80

-- Auto-indent after pasting
-- This is nice but it moves the cursor; figure out something better
-- vim.keymap.set("n", "p", "p=']", { silent = true, remap = true })

-- Always draw the signcolumn
vim.opt.signcolumn = "yes"
