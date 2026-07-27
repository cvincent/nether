return {
  "nanozuki/tabby.nvim",

  config = function()
    -- Persist tab names
    vim.opt.sessionoptions:append("globals")

    require("tabby").setup({
      line = function(line)
        return {
          {
            {
              " " .. vim.fn.fnamemodify(vim.uv.cwd(), ":t") .. " ",
              hl = "TabLineSel",
            },
            line.sep('', "TabLineSel", "TabLineFill"),
          },
          line.tabs().foreach(function(tab)
            local hl = tab.is_current() and "TabLineSel" or "TabLine"
            local name = tab.name():gsub("%[%d+%+%]$", "")

            return {
              line.sep("", hl, "TabLineFill"),
              { tab.number(), margin = " " },
              name,
              line.sep("", hl, "TabLineFill"),
              hl = hl,
              margin = " ",
            }
          end)
        }
      end,
    })
  end,
}
