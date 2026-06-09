return {
  "jmbuhr/otter.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter" },

  ft = { "elixir", "heex", "eelixir" },

  opts = {
    lsp = { diagnostic_update_events = { "BufWritePost" } },
    buffers = { set_filetype = true, write_to_disk = false },
    handle_leading_whitespace = true,
  },

  config = function(_, opts)
    require("otter").setup(opts)

    -- TODO: This goes with the heex stuff in nvim-treesitter.lua. We should
    -- ultimately extract it all into a local plugin so it's grouped together.
    -- *** Critical bug fix ***
    -- otter-ls forwards to the hidden buffer with vim.lsp.buf_request, whose
    -- callback fires once PER client and replies on the FIRST to answer. With
    -- cssls + css_variables both attached, the one returning nothing at the
    -- cursor (e.g. css_variables on a plain property) answers first and shadows
    -- the other → ZERO completions. Upstream is still first-wins. Wrap
    -- buf_request to AGGREGATE: query all completion clients on the otter
    -- buffer and reply once with merged items. (Use client:request, not
    -- buf_request_all — that's built on buf_request and would recurse.)
    if not vim.g.__otter_completion_aggregation then
      vim.g.__otter_completion_aggregation = true
      local ms = vim.lsp.protocol.Methods
      local orig = vim.lsp.buf_request
      local function is_otter_buf(b)
        local ok, keeper = pcall(require, "otter.keeper"); if not ok then return false end
        for _, raft in pairs(keeper.rafts or {}) do
          for _, n in pairs(raft.buffers or {}) do if n == b then return true end end
        end
        return false
      end
      vim.lsp.buf_request = function(bufnr, method, params, handler)
        if method ~= ms.textDocument_completion or not is_otter_buf(bufnr) then
          return orig(bufnr, method, params, handler)
        end
        local clients = vim.lsp.get_clients({ bufnr = bufnr, method = method })
        local items, remaining, replied = {}, #clients, false
        local function reply()
          if not replied then
            replied = true
            handler(nil, { isIncomplete = true, items = items },
              { bufnr = bufnr, method = method, params = params })
          end
        end
        if remaining == 0 then
          reply(); return {}
        end
        local function on_one(result)
          if result then for _, it in ipairs(result.items or result) do items[#items + 1] = it end end
          remaining = remaining - 1; if remaining == 0 then reply() end
        end
        for _, c in ipairs(clients) do
          local ok = c:request(method, params, function(_, r) on_one(r) end, bufnr)
          if not ok then on_one(nil) end
        end
        return {}
      end
    end

    -- Activate on each elixir/heex buffer (otter is graceful when there's none).
    local grp = vim.api.nvim_create_augroup("otter-elixir-heex", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = grp,
      pattern = { "elixir", "heex", "eelixir" },
      callback = function() pcall(require("otter").activate, { "javascript", "css" }, true, true) end,
    })
  end,
}
