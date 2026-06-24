return {
  "mrcjkb/rustaceanvim",
  -- To avoid being surprised by breaking changes,
  -- I recommend you set a version range
  -- ^9 requires NeoVim 0.12
  version = "^8",
  -- This plugin implements proper lazy-loading (see :h lua-plugin-lazy).
  -- No need for lazy.nvim to lazy-load it.
  lazy = false,

  init = function()
    vim.g.rustaceanvim = {
      server = {
        capabilities = {
          textDocument = {
            completion = {
              completionItem = {
                -- Fix completion. This is a temporary fix and should eventually
                -- not be needed: https://github.com/mrcjkb/rustaceanvim/discussions/937
                insertReplaceSupport = true,
              },
            },
          },
        },
      },
    }
  end,

  -- rust_analyzer = {
  --   tools = {
  --     check = { command = "clippy", },
  --     hover_actions = { replace_builtin_hover = true },
  --     code_actions = { ui_select_fallback = true },
  --   },

  --   server = {
  --     settings = {
  --       ["rust-analyzer"] = {
  --         check = { command = "clippy", },
  --       },
  --     },
  --   },
  -- },
}
