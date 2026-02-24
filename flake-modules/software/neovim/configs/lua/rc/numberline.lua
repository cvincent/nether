vim.o.number = true
vim.o.relativenumber = true

local function number_toggle()
  if vim.o.relativenumber then
    vim.o.number = true
    vim.o.relativenumber = false
  else
    vim.o.number = true
    vim.o.relativenumber = true
  end
end

vim.keymap.set("n", "<c-n>", number_toggle)

local deny = { "fzf" }

local function is_denied()
  return vim.tbl_contains(deny, vim.bo.filetype) or not vim.o.number
end

local augroup = vim.api.nvim_create_augroup("NumberToggle", { clear = true })

vim.api.nvim_create_autocmd("FocusLost", {
  group = augroup,
  callback = function()
    if not is_denied() then
      vim.o.number = true
      vim.o.relativenumber = false
    end
  end,
})

vim.api.nvim_create_autocmd("FocusGained", {
  group = augroup,
  callback = function()
    if not is_denied() then
      vim.o.relativenumber = true
    end
  end,
})

vim.api.nvim_create_autocmd("WinLeave", {
  group = augroup,
  callback = function()
    if not is_denied() then
      vim.o.number = true
      vim.o.relativenumber = false
    end
  end,
})

vim.api.nvim_create_autocmd("WinEnter", {
  group = augroup,
  callback = function()
    if not is_denied() then
      vim.o.relativenumber = true
    end
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  group = augroup,
  callback = function()
    if not is_denied() then
      vim.o.relativenumber = true
    end
  end,
})
