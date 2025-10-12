return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  ---@module "ibl"
  ---@type ibl.config
  opts = {
    indent = { highlight = { "VertSplit" }, char = "▏" },
    scope = {
      enabled = true,
      show_start = false,
      show_end = false,
      include = {
        node_type = { ["*"] = { "*" } },
      },
    },
  },
}
