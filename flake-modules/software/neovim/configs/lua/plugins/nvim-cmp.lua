return {
  {
    "hrsh7th/nvim-cmp",

    config = function()
      vim.api.nvim_command("set completeopt=menu,menuone,noselect")

      local cmp = require("cmp")
      local luasnip = require("luasnip")

      require("luasnip.loaders.from_snipmate").lazy_load()

      if IsPluginInstalled("vim-matchup") then
        -- vim-matchup causes the completion menu to immediately insert and
        -- select a completion in some situations while wiping out the rest of
        -- the menu; for me it was always inside <% erb %> regions. This works
        -- around it by temporarily disabling the offending vim-matchup module
        -- while the completion menu is open.
        cmp.event:on("menu_opened", function()
          vim.b.matchup_matchparen_enabled = false
        end)
        cmp.event:on("menu_closed", function()
          vim.b.matchup_matchparen_enabled = true
        end)
      end

      cmp.setup({
        window = {
          completion = { winblend = 15 },
          documentation = { winblend = 15 }
        },

        preselect = cmp.PreselectMode.None,

        formatting = {
          fields = { "abbr", "kind", "menu" },
          expandable_indicator = true,
          format = function(_, vim_item)
            local abbr = vim_item.abbr or ""
            local truncated_abbr = vim.fn.strcharpart(abbr, 0, 80)
            if truncated_abbr ~= abbr then
              vim_item.abbr = truncated_abbr .. "…"
            end
            local menu = vim_item.menu or ""
            local truncated_menu = vim.fn.strcharpart(menu, 0, 40)
            if truncated_menu ~= menu then
              vim_item.menu = truncated_menu .. "…"
            end
            return vim_item
          end,
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
                end,
                keyword_pattern = [[\k\+]]
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
