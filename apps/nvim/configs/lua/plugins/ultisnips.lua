return {
  {
    "SirVer/ultisnips",

    enabled = false,

    dependencies = {
      "honza/vim-snippets", -- Collection of predefined snippets
    },

    init = function()
      vim.api.nvim_exec([[
        let g:UltiSnipsExpandOrJumpTrigger = "<c-k>"
        let g:UltiSnipsJumpBackwardTrigger = "<c-j>"
        let g:UltiSnipsSnippetDirectories = ["UltiSnips", "mysnippets"]
      ]], true)

      vim.api.nvim_create_autocmd("User", {
        pattern = "UltiSnipsEnterFirstSnippet",
        callback = function()
          -- Some plugin, maybe vim-surround, sets a select-mode mapping for "s"
          -- that we don't actually use, but which screws up our snippet
          -- replacements if we start with an "s"; here we disable that mapping,
          -- if it's enabled, the first time we expand a snippet
          if vim.fn.maparg("s", "s") == "S" then
            vim.keymap.del("s", "s")
          end
        end,
      })
    end,
  },
}
