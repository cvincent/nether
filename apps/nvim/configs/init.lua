-- TODO:
-- x Color settings (rc/colors.vim)
-- x Arrow newlines are unimpaired + rc/unimpaired.vim
-- x vim-obsession
-- x Some autoclose thing, hopefully one that doesn't suck
-- x Highlight current search match...using vim-searchlight before
-- x Some hlsearch thing...we were using vim-cool before I think
-- x Smooth scroll
-- x Some better notes plugin, or maybe a custom solution
-- x Fugitive and shortcuts, of course
-- x Signify or similar for sign column diffs (rc/vim-signify.vim)
-- x Fast, modern statusline
-- x Port in numberline config
-- x Modern snippets, maybe LSP integration?
-- x Smart case isn't working for */#; I guess that's always been the case, oh well
-- x Completion; was using nvim-cmp before
-- x Figured out why fzf window sometimes pops in and out, it's while vim-cool is highlighting I think
-- x Bring back fzf/telescope for git checkout
-- x Look into Telescope alternative to fzf-lua
-- x QFEnter maybe? (see rc); might not need, we use ]q and [q these days
-- x sessionopts localoptions saves winfixwidth but also causes all <buffer>
--   mappings to be saved...this fucks shit up in all kinds of ways, like when
--   switching plugins around and such. If we could just delete every line
--   starting with a mapping command from Session.vim, that would fix it I think.
--   Edit: We're just not using winfixwidth anymore.
-- * Maybe bring back matchup (see rc); do we really need it?
-- * Look at nvim-dap; built-in LSP debugger, supports Elixir!
-- * Indent lines?
-- * Some kind of Slime-like, maybe actually tpope's Dispatch
-- * Do we need FixCursorHold? Fixes perf issues in some plugins using cursor move aucmds
-- * Will inevitably, eventually need vim-rails and rc again, along with rspec and ruby
-- * Inspiration:
--   * https://github.com/NvChad/NvChad

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({"git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath})

  if vim.v..shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." }
    }, true, {})
  end
end
vim.opt.rtp:prepend(lazypath)

-- Space as leader; apparently needs to be set before Lazy init
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("lazy").setup({
  spec = {
    ------------------
    -- DEPENDENCIES --
    ------------------

    -- Needed by gitsigns.nvim and nvim-telescope, maybe useful more generally
    -- TODO: Make this a Lazy dependency where needed?
    "nvim-lua/plenary.nvim",

    ------------------------
    -- LSP AND COMPLETION --
    ------------------------

    -- Basic LSP config
    "neovim/nvim-lspconfig",

    -----------
    -- TPOPE --
    -----------

    -- Sick search/replace with smart_caseRecognitions
    "tpope/vim-abolish",

    -- Commenting with motions
    "tpope/vim-commentary",

    -- Unix commands
    "tpope/vim-eunuch",

    -- Git integration
    "tpope/vim-fugitive",

    -- GBrowse
    "tpope/vim-rhubarb",

    -- Easier session management
    "tpope/vim-obsession",

    -- Dot repeat support for various plugins
    "tpope/vim-repeat",

    -- Automatically detect a file's tab settings
    "tpope/vim-sleuth",

    -- Surrounding characters, should just be part of default Vim
    "tpope/vim-surround",

    -- Various handy bracket mappings
    "tpope/vim-unimpaired",

    -- Better netrw
    "tpope/vim-vinegar",

    -- Shortcuts for HTML
    "tpope/vim-ragtag",

    -- Projections
    "tpope/vim-projectionist",
    "andyl/vim-projectionist-elixir",

    -- Fluid testing
    "vim-test/vim-test",

    -----------------------
    -- LANGUAGE SPECIFIC --
    -----------------------

    "LnL7/vim-nix",
    "elixir-editors/vim-elixir",

    ----------
    -- MISC --
    ----------

    -- Fuzzy finders
    { "nvim-telescope/telescope.nvim", branch = "0.1.x" },
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },

    -- Disable search highlight after moving cursor
    "romainl/vim-cool",

    -- Highlight current search match
    "PeterRincker/vim-searchlight",

    -- Easy px to rem conversion
    { "jsongerber/nvim-px-to-rem", config = true },

    -- TODO: Set this up at some point
    -- "n0v1c3/vira",

    { import = "plugins" },
  },
})

require("rc")
