return {
  {
    "hrsh7th/nvim-cmp",

    config = function()
      vim.api.nvim_command("set completeopt=menu,menuone,noselect")

      local cmp = require("cmp")
      local luasnip = require("luasnip")

      require("luasnip.loaders.from_snipmate").lazy_load()

      cmp.setup({
        window = {
          -- completion = cmp.config.window.bordered(),
          -- documentation = cmp.config.window.bordered(),
        },

        mapping = cmp.mapping.preset.insert({
          ['<c-u>'] = cmp.mapping.scroll_docs(-4),
          ['<c-d>'] = cmp.mapping.scroll_docs(4),

          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.locally_jumpable(1) then
              luasnip.jump(1)
            elseif luasnip.choice_active() then
              luasnip.change_choice(1)
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            elseif luasnip.choice_active() then
              luasnip.change_choice(-1)
            else
              fallback()
            end
          end, { "i", "s" }),

          ['<c-space>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              if luasnip.expandable() then
                luasnip.expand()
              else
                cmp.confirm({
                  select = false,
                })
              end
            else
              fallback()
            end
          end),

          ['<c-e>'] = function(fallback)
            fallback()
          end
          -- ['<cr>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),

        snippet = {
          expand = function(args)
            require 'luasnip'.lsp_expand(args.body)
          end
        },

        sources = cmp.config.sources(
          {
            { name = "nvim_px_to_rem" },
            { name = "nvim_lsp" },
            { name = "luasnip" },
          },
          {
            {
              name = "buffer",
              option = {
                -- Complete from all visible buffers
                get_bufnrs = function()
                  local bufs = {}
                  for _, win in ipairs(vim.api.nvim_list_wins()) do
                    bufs[vim.api.nvim_win_get_buf(win)] = true
                  end
                  return vim.tbl_keys(bufs)
                end
              }
            },
          }
        ),
      })
    end,

    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- LSP completion source
      -- "quangnguyen30192/cmp-nvim-ultisnips", -- Snippet completion
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-buffer", -- Buffer words completion source
    },
  },
}
