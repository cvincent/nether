vim.cmd.runtime("lua/luasnips/eruby.lua")

local ts_utils = require("nvim-treesitter.ts_utils")

--- vim-rails depends on vanilla Vim syntax highlighting to determine whether
--- `gf` should look for a partial. Treesitter highlighting clobbers this, even
--- with additional_vim_regex_highlighting, despite what some have reported. The
--- following fixes it by using Treesitter to get the node type at the cursor,
--- then calling the vim-rails function if we are in a Ruby string. Otherwise,
--- it falls back to the original `gf` mapping, likely LSP go-to-definition.

local original_gf = vim.fn.maparg("gf", "n", false, true)

pcall(vim.api.nvim_del_keymap, "n", "gf")

vim.keymap.set("n", "gf", function()
  local node = ts_utils.get_node_at_cursor()

  if node and (node:type() == "string" or node:type() == "string_content") then
    local filename = vim.fn["rails#ruby_cfile"]()
    if filename and filename ~= "" then
      return vim.cmd("edit " .. vim.fn.fnameescape(filename))
    end
  end

  if original_gf and original_gf.rhs then
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes(original_gf.rhs, true, false, true),
      "n",
      true
    )
  else
    vim.cmd("normal! gf")
  end
end, {
  desc = "Smart gf for Rails strings",
  buffer = true,
})
