return {
  "stevearc/conform.nvim",
  opts = {
    -- notify_on_error = false,
    -- default_format_opts = { quiet = true },

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

    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*",
      group = "Autoformat",
      callback = function(args)
        local ignore_filetypes = { "oil" }
        if vim.tbl_contains(ignore_filetypes, vim.bo[args.buf].filetype) then
          return
        end

        if vim.b.autoformat == nil then
          vim.b.autoformat = true
        end

        if vim.b.autoformat then
          -- For async formatting, formatting is discarded if the buffer was
          -- modified before the formatter completes, which includes writing to
          -- disk. Therefore, we use BufWritePost instead of BufWritePre. Then,
          -- after the formatter has run, we issue `:noa w` to write the file
          -- out again but skipping autocmds.
          --
          -- Note, I think doing this async breaks quiet... Also, the `:noa w`
          -- invocation fires on whatever buffer is focused, which we often have
          -- changed after write...
          require("conform").format(
            {
              bufnr = args.buf,
              lsp_format = "fallback",
              async = true,
              -- quiet = true,
            },
            function() vim.cmd("noa w") end
          )
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
