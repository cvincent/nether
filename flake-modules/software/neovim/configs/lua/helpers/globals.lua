function IsPluginInstalled(plugin)
  local plugin = require("lazy.core.config").plugins[plugin]
  return plugin and plugin._.installed
end

function DisableFormatOnWrite(pattern)
  vim.api.nvim_create_autocmd("LspAttach", {
    pattern = pattern,
    callback = function()
      vim.api.nvim_del_augroup_by_name("lsp-format-on-write")
    end,
  })
end

IconsPlugin = "nvim-tree/nvim-web-devicons"

function CallPlugMapping(name)
  local t = function(keycode) return vim.api.nvim_replace_termcodes(keycode, true, false, true) end
  vim.api.nvim_feedkeys(t "<Plug>" .. name, "v", true)
end

NixToNvim = dofile(vim.fn.fnamemodify(vim.fn.stdpath("config"), ":h") .. "/nix-to-nvim.lua")

-- Keeping this global for the ease of the nvr-remote-edit script
vim.api.nvim_create_user_command("RemoteFloatingEdit", function()
  local ui = vim.api.nvim_list_uis()[1]
  local buf = vim.api.nvim_create_buf(false, true)

  local quick_win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = ui.height * (1 / 6),
    col = ui.width * (1 / 3),
    width = math.floor(ui.width * (1 / 3)),
    height = math.floor(ui.height * (2 / 3)),
    border = "rounded",
  })

  vim.api.nvim_buf_attach(buf, false, {
    on_lines = function()
      vim.api.nvim_buf_detach(buf)
      -- setup_buffer_keymaps(buf)
    end
  })

  vim.api.nvim_command("set winblend=15")

  vim.api.nvim_create_autocmd("BufEnter", {
    once = true,
    callback = function()
      if vim.api.nvim_get_current_win() == quick_win then
        vim.api.nvim_buf_set_keymap(buf, 'n', '<leader>q', ':bd<CR>', {})
      end
    end,
  })
end, {})
