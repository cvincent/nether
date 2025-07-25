return {
  "Raimondi/delimitMate",
  lazy = false,
  priority = 100,
  init = function()
    vim.g.delimitMate_expand_cr = 2
    vim.g.delimitMate_expand_space = 1
    vim.g.delimitMate_matchpairs = "(:),[:],{:}"
  end
}
