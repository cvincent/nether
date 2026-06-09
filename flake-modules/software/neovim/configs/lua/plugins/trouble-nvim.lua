return {
  {
    "folke/trouble.nvim",

    opts = {
      focus = true,

      modes = {
        diagnostics = {
          preview = {
            type = "split",
            relative = "win",
            position = "right",
            size = 0.5,
          },
        },
      },
    },

    cmd = "Trouble",
    keys = {},
  },

  {
    "artemave/workspace-diagnostics.nvim"
  },
}
