return {
  -- Finally makes */# use smartcase
  "haya14busa/vim-asterisk",

  init = function()
    -- Use the plugin's "z" mappings by default, which stay on the current word
    -- when initiating the search
    vim.keymap.set("n", "*", "<Plug>(asterisk-z*)")
    vim.keymap.set("n", "#", "<Plug>(asterisk-z#)")
    vim.keymap.set("n", "g*", "<Plug>(asterisk-gz*)")
    vim.keymap.set("n", "g#", "<Plug>(asterisk-gz#)")

    -- Also keep our position _within_ the word on further selections
    vim.g["asterisk#keeppos"] = 1
  end
}
