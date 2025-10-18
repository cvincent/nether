local M = {}

local ls = require("luasnip")

local snippet = ls.snippet

local c = ls.choice_node
local d = ls.dynamic_node
local f = ls.function_node
local i = ls.insert_node
local r = ls.restore_node
local s = ls.snippet_node
local t = ls.text_node

local rep = require("luasnip.extras").rep
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local conds = require("luasnip.extras.conditions")
local conds_expand = require("luasnip.extras.conditions.expand")

M.visual_or_insert = function(default)
  return conds.make_condition(function(_, parent)
    if (#parent.snippet.env.LS_SELECT_RAW > 0) then
      return s(nil, { t(parent.snippet.env.LS_SELECT_RAW), i(1) })
    else
      return s(nil, i(1, default))
    end
  end)
end

return M
