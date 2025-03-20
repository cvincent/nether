return {
  "stevearc/conform.nvim",
  -- opts = {
  --   format_on_save = {
  --     -- These options will be passed to conform.format()
  --     timeout_ms = 500,
  --     lsp_format = "fallback",
  --   },
  -- },
  init = function()
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*",
      callback = function(args)
        if vim.b.autoformat == nil then
          vim.b.autoformat = true
        end

        if vim.b.autoformat then
          vim.print("FOMRAT")
          require("conform").format({ bufnr = args.buf, lsp_format = "fallback" })
        end
      end,
    })

    vim.api.nvim_create_user_command("AutoformatToggle", function()
      local new_val = not vim.b.autoformat
      vim.b.autoformat = new_val
    end, {})
  end
}
