return {
  {
    "hrsh7th/nvim-cmp",

    config = function()
      vim.api.nvim_command("set completeopt=menu,menuone,noselect")

      local cmp = require("cmp")

      cmp.setup({
        window = {
          -- completion = cmp.config.window.bordered(),
          -- documentation = cmp.config.window.bordered(),
        },

        mapping = cmp.mapping.preset.insert({
          ['<c-u>'] = cmp.mapping.scroll_docs(-4),
          ['<c-d>'] = cmp.mapping.scroll_docs(4),
          ["<tab>"] = cmp.mapping.select_next_item(),
          ["<s-tab>"] = cmp.mapping.select_prev_item(),
          ['<c-space>'] = cmp.mapping.confirm({ select = false }),
          ['<c-e>'] = function(fallback)
            fallback()
          end
          -- ['<cr>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),

        sources = cmp.config.sources(
          {
            { name = "nvim_px_to_rem" },
            { name = "nvim_lsp" },
            { name = "ultisnips" },
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
      "hrsh7th/cmp-nvim-lsp",                -- LSP completion source
      "quangnguyen30192/cmp-nvim-ultisnips", -- Snippet completion
      "hrsh7th/cmp-buffer",                  -- Buffer words completion source
    },
  },
}
