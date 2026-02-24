vim.opt.number = true
vim.opt.relativenumber = true

vim.api.nvim_exec2([[
  function! NumberToggle()
    if(&relativenumber == 1)
      set number
      set norelativenumber
    else
      set number
      set relativenumber
    endif
  endfunc

  nnoremap <C-N> :call NumberToggle()<CR>

  let deny = ['fzf']
  au FocusLost * if index(deny, &ft) < 0 | set number
  au FocusLost * if index(deny, &ft) < 0 | set norelativenumber
  au FocusGained * if index(deny, &ft) < 0 | set relativenumber
  au WinLeave * if index(deny, &ft) < 0 | set number
  au WinLeave * if index(deny, &ft) < 0 | set norelativenumber
  au WinEnter * if index(deny, &ft) < 0 | set relativenumber
  au BufEnter * if index(deny, &ft) < 0 | set relativenumber
]], {})
