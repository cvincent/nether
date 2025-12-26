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

local find_node_ancestor = require("ts_utils").find_node_ancestor

local vars_query = vim.treesitter.query.parse("ruby", [[
  ;query
  (method_parameters (identifier) @var)
  (method_parameters (optional_parameter (identifier) @var))
  (method_parameters (keyword_parameter (identifier) @var))
]])

local params_at_pos = function(pos)
  local node = vim.treesitter.get_node({ pos = pos })

  if not node then
    return {}
  end

  local params_node = find_node_ancestor({ "method_parameters" }, node)

  if not params_node then
    return {}
  end

  local captures = {}

  for _, param_node in vars_query:iter_captures(params_node, 0) do
    local param = vim.treesitter.get_node_text(param_node, 0)

    if param ~= "" then
      table.insert(captures, param)
    end
  end

  return captures
end

local method_body = function(args, parent)
  local method_name = args[1][1]

  if method_name ~= "initialize" then
    return s(nil, i(1, "# body"))
  end

  local params = params_at_pos(parent.insert_nodes[2]:get_buf_position())

  local nodes = {}

  for _, param in ipairs(params) do
    table.insert(nodes, t({ "@" .. param .. " = " .. param }))
    table.insert(nodes, t({ "", "  " }))
  end

  table.remove(nodes, #nodes)

  return s(nil, nodes)
end

vim.keymap.set("n", "<leader>rt", params_at_pos)

local h = require("luasnips.helpers")

local underscore_to_pascal = function(str)
  return str
      :gsub("_(%w)", function(match) return match:upper() end)
      :gsub("^%w", function(match) return match:upper() end)
end

local default_class_name = function()
  local name = underscore_to_pascal(vim.fn.expand("%:t:r"))
  return s(nil, i(1, name))
end

ls.add_snippets("ruby", {
  -- This would need a condition function that returns false if the next
  -- character after the cursor is another "|"
  -- snippet(
  --   {
  --     trig = "|",
  --     snippetType = "autosnippet"
  --   },
  --   { t("|"), i(1), t("|") }
  -- ),

  snippet({
    trig = "cla",
    condition = conds_expand.line_begin,
  }, {
    s(1, fmta(
      [[
        class <><>
          <>
        end
      ]],
      {
        d(1, default_class_name),
        c(2, {
          s(nil, { t(" < "), i(1, "ParentClass") }, { dedent = false }),
          { i(1) }
        }),
        d(3, h.visual_or_insert("# class"))
      }
    ))
  }),

  snippet({
    trig = "def",
    condition = conds_expand.line_begin,
  }, fmta(
    [[
      def <><>
        <><>
      end
    ]],
    {
      c(1, {
        i(1, "method_name"),
        i(1, "initialize"),
      }),
      c(2, {
        { t("("), i(1, "args"), t(")") },
        { i(1) },
      }),
      d(3, method_body, { 1, 2 }),
      i(0)
    }
  )),

  snippet({
    trig = "@=",
    condition = conds_expand.line_begin,
  }, fmta([[@<> = <>]], { i(1, "var"), rep(1) })),

  snippet({
    trig = "do",
    condition = conds_expand.line_end * h.outside_snippet,
    show_condition = conds_expand.line_end * h.outside_snippet,
  }, {
    c(1, {
      s(nil,
        fmta(
          [[
            <>do<>
              <>
            end
          ]],
          {
            i(1),
            c(2, {
              s(nil, fmta(" |<>|", { r(1, "args") }, { dedent = false })),
              { i(1) }
            }),
            d(3, h.visual_or_insert("# code"))
          }
        ), {
          stored = { args = "args" },
        }
      ),
      s(nil,
        fmta(
          [[<>{<> <> }]],
          {
            i(1),
            c(2, {
              s(nil, fmta(" |<>|", { r(1, "args") }, { dedent = false })),
              { i(1) }
            }),
            d(3, h.visual_or_insert("code"))
          }
        )
      )
    }, {
      restore_cursor = true
    })
  }, { stored = { ["args"] = i(1, "args") } }),

  snippet({
    trig = "{",
  }, {
    t("{ "),
    c(1, {
      { t("|"), i(1, "args"), t("| ") },
      { i(1) }
    }),
    i(0),
    t(" "),
  }),

  -- snippet({
  --   trig = "let",
  --   condition = conds_expand.line_begin * h.outside_snippet,
  --   show_condition = h.outside_snippet,
  -- }, {
  --   t("let"),
  --   c(1, {
  --     t(""),
  --     t("!"),
  --   }),
  --   t("(:"),
  --   i(2, "record"),
  --   t(") "),
  --   c(3, {
  --     { t("{ "), s(nil, c(1, c())) }
  --   })
  -- }),
}, { key = "ruby" })
