return {
  "inkarkat/vim-EnhancedJumps",

  dependencies = {
    "inkarkat/vim-ingo-library",
  },

  init = function()
    vim.g.EnhancedJumps_no_mappings = 1
    vim.g.EnhancedJumps_CaptureJumpMessages = 0

    vim.keymap.set("n", "<leader><c-o>", "<plug>EnhancedJumpsRemoteOlder")
    vim.keymap.set("n", "<leader><c-i>", "<plug>EnhancedJumpsRemoteNewer")

    vim.keymap.set("n", "g;", "<plug>EnhancedJumpsFarFallbackChangeOlder")
    vim.keymap.set("n", "g,", "<plug>EnhancedJumpsFarFallbackChangeNewer")
  end,
}
