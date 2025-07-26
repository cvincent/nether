return {
  "shaunsingh/nord.nvim",
  init = function()
    local colors = require("nord.colors")

    vim.g.nord_disable_background = true
    vim.g.nord_italic = false
    vim.g.nord_bold = false

    require("nord").set()

    vim.api.nvim_command("hi! Pmenu blend=15")
    vim.api.nvim_command("hi! Pmenu guibg=" .. colors.nord0_gui)

    vim.api.nvim_command("hi! Searchlight guibg=" .. colors.nord13_gui .. " guifg=" .. colors.nord0_gui)
    vim.api.nvim_command("hi! IncSearch   guibg=" .. colors.nord13_gui .. " guifg=" .. colors.nord0_gui)

    vim.api.nvim_command("hi! GitSignsAdd           guifg=" .. colors.nord14_gui)
    vim.api.nvim_command("hi! GitSignsStagedAdd     guifg=" .. colors.nord14_gui)
    vim.api.nvim_command("hi! GitSignsChange        guifg=" .. colors.nord13_gui)
    vim.api.nvim_command("hi! GitSignsStagedChange  guifg=" .. colors.nord13_gui)
    vim.api.nvim_command("hi! GitSignsDelete        guifg=" .. colors.nord11_gui)
    vim.api.nvim_command("hi! GitSignsStagedDelete  guifg=" .. colors.nord11_gui)

    vim.api.nvim_command("hi! WinSeparator  guifg=" .. colors.nord1_gui)
    vim.api.nvim_command("hi! CursorLine    guibg=" .. colors.nord0_gui)
    vim.api.nvim_command("hi! FloatBorder   guifg=" .. colors.nord1_gui .. "  guibg=" .. colors.nord0_gui)

    vim.api.nvim_command("hi! TelescopeTitle          guifg=" .. colors.nord13_gui .. " guibg=" .. colors.nord0_gui)
    vim.api.nvim_command("hi! TelescopePreviewBorder  guifg=" .. colors.nord1_gui .. "  guibg=" .. colors.nord0_gui)
    vim.api.nvim_command("hi! TelescopePromptBorder   guifg=" .. colors.nord1_gui .. "  guibg=" .. colors.nord0_gui)
    vim.api.nvim_command("hi! TelescopeResultsBorder  guifg=" .. colors.nord1_gui .. "  guibg=" .. colors.nord0_gui)
    vim.api.nvim_command("hi! TelescopeNormal                                           guibg=" .. colors.nord0_gui)

    vim.api.nvim_command("hi! RenderMarkdownTableFill guibg=NONE")

    vim.api.nvim_command("hi! link NonText Comment")
    vim.api.nvim_command("hi! @comment guifg=" .. colors.nord9_gui)

    vim.api.nvim_command("hi! @module guifg=" .. colors.nord13_gui)
    vim.api.nvim_command("hi! @type guifg=" .. colors.nord13_gui)
    vim.api.nvim_command("hi! @constructor guifg=" .. colors.nord13_gui)
    vim.api.nvim_command("hi! @string.special.symbol guifg=" .. colors.nord7_gui)

    -- Ruby instance vars
    vim.api.nvim_command("hi! @variable.member guifg=" .. colors.nord13_gui)

    vim.api.nvim_command("hi! link @keyword.function @keyword")

    vim.api.nvim_command("hi! MatchParen gui=underline")
  end
}
