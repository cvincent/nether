require("neorg").setup({
  load = {
    ["core.defaults"] = {},
    ["core.keybinds"] = {
      config = {
        hook = function(keybinds)
          -- None of this does anything right now for some reason
          keybinds.unmap("norg", "n", "<cr>")
          keybinds.remap_key("norg", "n", "<cr>", "<c-cr>")
        end,
      },
    },
    ["core.concealer"] = {
      config = {
        icons = {
          todo = {
            cancelled = { icon = "" },
            done = { icon = "✓" },
            on_hold = { icon = "" },
            pending = { icon = "⏱" },
            recurring = { icon = "↺" },
            uncertain = { icon = "" },
            undone = { icon = " " },
            urgent = { icon = "⚠" },
          },
        },
      },
    },
    ["core.esupports.indent"] = {
      config = {
        indents = {
          heading1 = { indent = 0 },
          heading2 = { indent = 1 },
          heading3 = { indent = 2 },
          heading4 = { indent = 3 },
          heading5 = { indent = 4 },
          heading6 = { indent = 5 },
        },
        tweaks = {
          unordered_list1 = 0,
          unordered_list2 = 1,
          unordered_list3 = 2,
          unordered_list4 = 3,
          unordered_list5 = 4,
          unordered_list6 = 5,
        },
      },
    },
    ["core.dirman"] = {
      config = {
        workspaces = {
          notes = "/backup/vim-notes/neorg",
        },
        default_workspace = "notes",
      },
    },
  },
})

vim.api.nvim_create_autocmd("filetype", {
  pattern = "norg",
  callback = function(ev)
    vim.b[0].delimitMate_expand_space = 0
    vim.api.nvim_command("set textwidth=80")
    vim.api.nvim_command("set breakindent linebreak")
    vim.api.nvim_command("imap <c-cr> <a-cr>")
    vim.api.nvim_create_user_command('CopyWorkNotes', function()
      -- Use pcall to swallow error if there's only one "-"; the e flag doesn't
      -- suppress it for some reason
      pcall(function() vim.api.nvim_command("normal! }{jt-okdV}k:s/\n[^-]//e<cr>") end)
      vim.api.nvim_command('normal! {jV}kv$h"+yu')
    end, {})
  end
})
