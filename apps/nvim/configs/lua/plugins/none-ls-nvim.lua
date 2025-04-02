return {
  "nvimtools/none-ls.nvim",
  opts = function(_, opts)
    local nls = require("null-ls")
    opts.sources = vim.list_extend(opts.sources or {}, {
      nls.builtins.diagnostics.credo.with({
        condition = function(utils)
          return utils.root_has_file(".credo.exs")
        end,
        args = {
          "credo", "suggest",
          "--format", "json",
          "--read-from-stdin",
          "--ignore-checks", "Credo.Check.Warning.WrongTestFileExtension",
          "$FILENAME",
        },
      }),
    })
  end,
}
