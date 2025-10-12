local M = {}

function M.find_node_ancestor(types, node)
  if not node then
    return nil
  end

  if vim.tbl_contains(types, node:type()) then
    return node
  end

  local parent = node:parent()

  return M.find_node_ancestor(types, parent)
end

return M
