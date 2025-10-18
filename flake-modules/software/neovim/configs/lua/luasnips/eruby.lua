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

local h = require("luasnips.helpers")

ls.add_snippets("eruby", {
  snippet({
      trig = "([%w_]+)%.each",
      trigEngine = "pattern",
    },
    fmt(
      [[
        <% {}.each do |{}| %>
          {}
        <% end %>
      ]],
      {
        f(function(_, snip) return snip.captures[1] end),
        i(1, "item"),
        d(2, h.visual_or_insert(""))
      }
    )
  ),

}, { key = "eruby", })
