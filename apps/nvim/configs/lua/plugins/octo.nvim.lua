return {
  "pwntester/octo.nvim",
  requires = {
    "nvim-lua/plenary.nvim",
    IconsPlugin,
  },
  opts = {
    ssh_aliases = { ["github%-elc"] = "github.com" }
  },
}
