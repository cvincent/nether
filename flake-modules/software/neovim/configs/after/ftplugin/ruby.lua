-- Improved Ruby support for the built-in matchit plugin (%)
vim.b.match_ignorecase = 0
vim.b.match_words =
    [[\%(\%(\%(^\|[;=]\)\s*\)\@<=\%(class\|module\|while\|begin\|until\|for\|if\|unless\|def\|case\)\|\<do\)\>:]] ..
    [[\<\%(else\|elsif\|ensure\|rescue\|when\)\>:\%(^\|[^.]\)\@<=\<end\>]]

vim.cmd.runtime("lua/luasnips/ruby.lua")
