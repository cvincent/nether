return {
  "nvim-neorg/neorg",
  dependencies = {
    "nvim-neorg/neorg-telescope",
    "luarocks.nvim",
    -- Lazy now supports luarocks out of the box, but maybe requires further
    -- configuration, or maybe I need to update it. Something about my recent
    -- config changes ended up forcing me to add these dependencies here
    -- explicitly.
    "nvim-neorg/lua-utils.nvim",
    "pysan3/pathlib.nvim",
    "nvim-neotest/nvim-nio",
  },

  -- Neorg unfortunately comes with some funk, like a longstanding bug that
  -- randomly errors out when dropping into vim-vinegar. But there's no reason to
  -- load Neorg outside my designated Neorg window, so we don't have to
  -- encounter these bugs on code projects.
  cond = vim.env.NEORG == "1",

  opts = {
    load = {
      ["core.defaults"] = {},
      ["core.keybinds"] = {},
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
            ordered_list1 = 0,
            ordered_list2 = 1,
            ordered_list3 = 2,
            ordered_list4 = 3,
            ordered_list5 = 4,
            ordered_list6 = 5,
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
      ["core.integrations.telescope"] = {
        config = {
          insert_file_link = {
            show_title_preview = false,
          },
        },
      },
    }
  },

  init = function()
    vim.api.nvim_create_autocmd("filetype", {
      pattern = "norg",
      callback = function(ev)
        vim.opt.formatoptions:append("t") -- Autowrap all text

        if require("lazy.core.config").plugins["delimitMate"] then
          vim.b[0].delimitMate_expand_space = 0
        end

        vim.api.nvim_command("set textwidth=80")
        vim.api.nvim_command("set breakindent linebreak")
        vim.api.nvim_command("set spell")
        vim.api.nvim_command("imap <c-cr> <a-cr>")

        vim.api.nvim_create_user_command('CopyWorkNotes', function()
          -- Use pcall to swallow error if there's only one "-"; the e flag doesn't
          -- suppress it for some reason
          pcall(function() vim.api.nvim_command("normal! }{jt-okdV}k:s/\n[^-]//e<cr>") end)
          vim.api.nvim_command('normal! {jV}kv$h"+yu')
        end, {})

        vim.api.nvim_create_autocmd("Filetype", {
          pattern = "norg",
          callback = function()
            vim.keymap.set("n", "<leader>flf", "<Plug>(neorg.telescope.insert_file_link)", { buffer = true })
            vim.keymap.set("n", "<leader>fll", "<Plug>(neorg.telescope.insert_link)", { buffer = true })

            vim.keymap.set("n", "<c-cr>", "<Plug>(neorg.esupports.hop.hop-link)", { buffer = true })

            -- These work okay, but only if you're on the same line as the
            -- bullet...likely fine enough for my use case.
            vim.keymap.set("i", "<c-.>", "<c-o>I -<esc>A", { buffer = true })
            vim.keymap.set("i", "<c-,>", "<c-o>:s/ -/<cr><esc>A", { buffer = true })

            -- Easily start a new todo *above* the current todo
            vim.keymap.set("i", "<s-cr>", "<c-o>yy<c-o>P<c-o>f)<c-o>2l<c-o>D<esc>A", { buffer = true })

            -- Easily insert current date or time
            vim.keymap.set("i", "<c-d>", "<c-r>=strftime('%D')<cr>. ", { buffer = true })
            vim.keymap.set(
              "i", "<c-t>", "<c-r>=substitute(tolower(strftime('%I:%M%p')), '^0', '', '')<cr>. ",
              { buffer = true }
            )
          end,
        })
      end,
    })
  end
}
