return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      javascript = { "prettier" },
      typescript = { "prettier" },

      nix = { "nixfmt" },

      ruby = { "rubocop" },
      eruby = { "erb_lint", "htmlbeautifier" },

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

      rubocop = {
        args = {
          "--server",
          "-a",
          "-f",
          "quiet",
          "--force-exclusion",
          "--except",
          "Lint/UselessAssignment",
          "--stderr",
          "--stdin",
          "$FILENAME",
        },
      },
    }
  },

  init = function()
    vim.api.nvim_create_augroup("Autoformat", { clear = true })

    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*",
      group = "Autoformat",
      callback = function(args)
        local ignore_filetypes = {}
        if vim.tbl_contains(ignore_filetypes, vim.bo[args.buf].filetype) then
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
