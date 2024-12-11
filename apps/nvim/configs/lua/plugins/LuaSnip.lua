return {
  -- Snippets engine
  {
    "L3MON4D3/LuaSnip",
    config = function ()
      vim.api.nvim_exec([[
        " press <Tab> to expand or jump in a snippet. These can also be mapped separately
        " via <Plug>luasnip-expand-snippet and <Plug>luasnip-jump-next.
        imap <silent><expr> <c-k> luasnip#expand_or_jumpable() ? '<plug>luasnip-expand-or-jump' : '<c-k>'
        " -1 for jumping backwards.
        inoremap <silent> <c-j> <cmd>lua require'luasnip'.jump(-1)<cr>

        snoremap <silent> <c-k> <cmd>lua require('luasnip').jump(1)<cr>
        snoremap <silent> <c-j> <cmd>lua require('luasnip').jump(-1)<cr>

        " For changing choices in choiceNodes (not strictly necessary for a basic setup).
        " imap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'
        " smap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'
      ]], true)

      require("luasnip.loaders.from_snipmate").lazy_load()
      require("luasnip.loaders.from_snipmate").lazy_load({ paths = "~/.config/nvim/snippets" })

      vim.api.nvim_create_autocmd("User", {
        pattern = "LuasnipPreExpand",
        callback = function ()
          vim.api.nvim_exec("sunmap s", true)
        end,
      })
    end
  },

  -- Collection of predefined snippets
  "honza/vim-snippets",
}
