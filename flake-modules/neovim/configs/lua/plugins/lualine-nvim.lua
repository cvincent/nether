return {
  "nvim-lualine/lualine.nvim",
  dependencies = { IconsPlugin, lazy = true },
  opts = {
    options = {
      globalstatus = false,

      section_separators = {
        left = "",
        right = ""
      },

      component_separators = {
        left = "",
        right = ""
      },
    },

    sections = {
      lualine_a = { "branch", "diff" },
      lualine_b = {},
      lualine_c = {
        {
          "filename",
          path = 1,
          shorting_target = 2
        },
      },
      lualine_x = {},
      lualine_y = { "diagnostics" },
      lualine_z = { "location" },
    },

    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {
        {
          "filename",
          path = 1,
          shorting_target = 2
        }
      },
      lualine_x = {},
      lualine_y = {},
      lualine_z = {},
    },
  },
}
