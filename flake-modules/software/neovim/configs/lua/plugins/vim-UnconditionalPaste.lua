return {
  "inkarkat/vim-UnconditionalPaste",

  init = function()
    -- TODO: This mapped a _lot_ of things by default, including mapping over
    -- `g,`. I really only came to the plugin for the two things mapped below.
    -- But I should read through the readme, I bet there are other useful things
    -- too.
    vim.g.UnconditionalPaste_no_mappings = 1

    vim.keymap.set("n", "gcp", "<Plug>UnconditionalPasteCharAfter")
    vim.keymap.set("n", "gcP", "<Plug>UnconditionalPasteCharAfter")
  end,
}
