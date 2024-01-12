-- if packer_plugins["nvim-cmp"] then
  vim.api.nvim_command("set completeopt=menu,menuone,noselect")

  local cmp = require("cmp")

  cmp.setup({
    snippet = {
      expand = function(args)
        require('luasnip').lsp_expand(args.body)
      end,
    },

    window = {
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    },

    mapping = cmp.mapping.preset.insert({
      ['<c-u>'] = cmp.mapping.scroll_docs(-4),
      ['<c-d>'] = cmp.mapping.scroll_docs(4),
      ["<tab>"] = cmp.mapping.select_next_item(),
      ["<s-tab>"] = cmp.mapping.select_prev_item(),
      ['<c-space>'] = cmp.mapping.complete(),
      ['<c-e>'] = function(fallback)
        fallback()
      end
      -- ['<cr>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),

    sources = cmp.config.sources(
      {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
      },
      {
        { name = 'buffer' },
      }
    ),
  })
-- end
