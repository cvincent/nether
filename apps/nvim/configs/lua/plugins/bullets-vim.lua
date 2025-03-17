return {
  "bullets-vim/bullets.vim",
  init = function()
    vim.g.bullets_checkbox_markers = " -x"
    vim.g.bullets_outline_levels = {}
    vim.g.bullets_max_alpha_characters = 0
    vim.g.bullets_set_mappings = 0

    -- Bring in only the mappings we want
    vim.keymap.set("i", "<cr>", "<Plug>(bullets-newline)")
    vim.keymap.set("i", "<c-cr>", "<cr>", { noremap = true })

    vim.keymap.set("n", "o", "<Plug>(bullets-newline)")
    vim.keymap.set("n", ">>", "<Plug>(bullets-demote)")
    vim.keymap.set("v", ">", "<Plug>(bullets-demote)")
    vim.keymap.set("n", "<<", "<Plug>(bullets-promote)")
    vim.keymap.set("v", "<", "<Plug>(bullets-promote)")
  end
}
