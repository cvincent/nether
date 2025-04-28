return {
  "MeanderingProgrammer/render-markdown.nvim",

  opts = {
    anti_conceal = { enabled = false },

    heading = {
      icons = {},
      backgrounds = {},
    },

    pipe_table = {
      enabled = true,
      preset = "round",
    },

    checkbox = {
      right_pad = 1,
      unchecked = { icon = "  [ ]" },
      checked = { icon = "  [󰄬]" },
      custom = {
        pending = {
          raw = "[-]",
          rendered = "  []",
          highlight = "RenderMarkdownTodo",
          scope_highlight = nil,
        },
      },
    },

    win_options = {
      concealcursor = { rendered = "n" },
    },
  },

  init = function()
  end
}
