" Copy of the default vim-test adapter for Busted, but altered slightly to run
" in headless NeoVim. I could not figure out a way to override just these bits,
" not in Lua nor Vimscript, from .nvim.lua, and if this file is defined you need
" to provide _all_ the relevant functions here.

" We should eventually switch to nvim-neotest, but that's not today.

function! test#lua#busted#executable() abort
  return "nvim"
endfunction

function! test#lua#busted#build_args(args) abort
  if empty(a:args)
    let l:dir = "flake-modules/software/neovim/configs/lua/spec"
    let l:cmd = "'PlenaryBustedDirectory " . l:dir . "'"
  else
    let l:last = a:args[-1]

    if l:last =~# "_spec\.lua$"
      let l:cmd = "'PlenaryBustedFile " . l:last . "'"
    endif
  endif

  return ["--headless", "-c", l:cmd]
endfunction

" The rest of these functions are directly copied from vim-test's original
" adapter, except one other small change:

if !exists('g:test#lua#busted#file_pattern')
  let g:test#lua#busted#file_pattern = '\v_spec\.(lua|moon)$'
endif

function! test#lua#busted#test_file(file) abort
  return a:file =~# g:test#lua#busted#file_pattern
endfunction

function! test#lua#busted#build_position(type, position) abort
  if a:type ==# 'nearest'
    let name = s:nearest_test(a:position)
    if !empty(name)
      " Plenary does not take a --filter argment; for "nearest", just test the
      " whole current file.
      return []
    else
      return [a:position['file']]
    endif
  elseif a:type ==# 'file'
    return [a:position['file']]
  else
    return []
  endif
endfunction

function! s:nearest_test(position) abort
  let name = test#base#nearest_test(a:position, g:test#lua#patterns)

  if !empty(name['test'])
    return s:escape_lua_pattern(name['test'][0])
  endif

  if !empty(name['namespace'])
    return s:escape_lua_pattern(name['namespace'][0])
  endif

  return ""
endfunction

" Escape Lua pattern magic characters with the Lua pattern escape character (%).
"
" The magic characters set are defined in the Lua docs at:
" https://www.lua.org/pil/20.2.html
function! s:escape_lua_pattern(pattern) abort
  let magic_characters = ["(", ")", "\\.", "%", "+", "-", "*", "?", "[", "\\^", "\\$"]
  let magic_str = join(magic_characters, "\\|")
  return substitute(a:pattern, "\\(" . magic_str . "\\)", "%\\1", "g")
endfunction
