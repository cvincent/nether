vim.opt.number = true
vim.opt.relativenumber = true

vim.api.nvim_exec([[

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

let blacklist = ['fzf']
au FocusLost * if index(blacklist, &ft) < 0 | set number
au FocusLost * if index(blacklist, &ft) < 0 | set norelativenumber
au FocusGained * if index(blacklist, &ft) < 0 | set relativenumber
au WinLeave * if index(blacklist, &ft) < 0 | set number
au WinLeave * if index(blacklist, &ft) < 0 | set norelativenumber
au WinEnter * if index(blacklist, &ft) < 0 | set relativenumber

]], true)
