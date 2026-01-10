return {
  "bullets-vim/bullets.vim",
  init = function()
    vim.g.bullets_checkbox_markers = " -x"
    vim.g.bullets_outline_levels = {}
    vim.g.bullets_max_alpha_characters = 0
    vim.g.bullets_set_mappings = 0

    vim.g.bullets_enabled_file_types = {
      "markdown",
      "text",
      "gitcommit",
      "scratch",
      "jjdescription"
    }

    vim.api.nvim_create_autocmd("filetype", {
      pattern = vim.g.bullets_enabled_file_types,
      callback = function()
        vim.keymap.set("i", "<cr>", "<Plug>(bullets-newline)", { buffer = true })
        vim.keymap.set("i", "<c-cr>", "<cr>", { noremap = true, buffer = true })

        vim.keymap.set("n", "o", "<Plug>(bullets-newline)", { buffer = true })
        vim.keymap.set("n", ">>", "<Plug>(bullets-demote)", { buffer = true })
        vim.keymap.set("v", ">", "<Plug>(bullets-demote)", { buffer = true })
        vim.keymap.set("n", "<<", "<Plug>(bullets-promote)", { buffer = true })
        vim.keymap.set("v", "<", "<Plug>(bullets-promote)", { buffer = true })
      end,
    })
  end
}
