local cl_back_skip_same_line = function()
  local starting_line = vim.fn.line(".")

  while vim.fn.line(".") == starting_line do
    if not pcall(vim.cmd.normal, { "g;", bang = true }) then
      vim.print("No more changes back.")
      break
    end
  end
end

local cl_fwrd_skip_same_line = function()
  local starting_line = vim.fn.line(".")

  while vim.fn.line(".") == starting_line do
    if not pcall(vim.cmd.normal, { "g,", bang = true }) then
      vim.print("No more changes forward.")
      break
    end
  end
end

vim.keymap.set("n", "g;", cl_back_skip_same_line)
vim.keymap.set("n", "g,", cl_fwrd_skip_same_line)
