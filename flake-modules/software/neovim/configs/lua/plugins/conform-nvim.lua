return {
  "stevearc/conform.nvim",
  opts = function()
    local opts = {
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },

        nix = { "nixfmt" },

        ruby = { "rubocop" },
        eruby = { "erb_lint", "htmlbeautifier" },

        sh = { "shfmt" },

        sql = {
          "pg_format",
          prepend_args = { "--no-grouping" }
        },
      },

      formatters = {
        erb_lint = {
          command = "erb_lint",
          stdin = false,
          args = { "--autocorrect", "--fail-level", "F", "$FILENAME" },
          async = true,
        },

        htmlbeautifier = { prepend_args = { "-b1" } },

        rubocop = {},
      }
    }

    local ignore_rubocop_fixes = table.concat({
      "Lint/LiteralAsCondition",
      "Lint/UselessAssignment",
      "Lint/Void",
      "Style/EmptyElse",
      "Style/RedundantBegin",
    }, ",")

    opts.formatters.rubocop.args = {
      "--server",
      "-a",
      "-f",
      "quiet",
      "--force-exclusion",
      "--except",
      ignore_rubocop_fixes,
      "--stderr",
      "--stdin",
      "$FILENAME",
    }

    return opts
  end,

  init = function()
    vim.api.nvim_create_augroup("Autoformat", { clear = true })

    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*",
      group = "Autoformat",
      callback = function(args)
        local ignore_filetypes = {}
        local path = vim.api.nvim_buf_get_name(0)

        if vim.tbl_contains(ignore_filetypes, vim.bo[args.buf].filetype)
            or vim.o.diff
            or path:match("^/tmp/") and not path:match("-query-")
        then
          return
        end

        if vim.b.autoformat == nil then
          vim.b.autoformat = true
        end

        if vim.b.autoformat then
          require("conform").format({ bufnr = args.buf, lsp_format = "fallback", timeout_ms = 10000 })
        end
      end,
    })

    vim.api.nvim_create_user_command("AutoformatToggle", function()
      local new_val = not vim.b.autoformat
      vim.b.autoformat = new_val
    end, {})

    vim.keymap.set("n", "<leader><s-f>", require("conform").format)
    vim.keymap.set("v", "<leader><s-f>", require("conform").format)
  end
}
