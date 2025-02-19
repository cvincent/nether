return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = false,
  ft = "markdown",
  dependencies = {
    "hrsh7th/nvim-cmp",
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },

  opts = {
    workspaces = {
      {
        name = "second-brain",
        path = "/backup/second-brain",
      },
    },

    completion = {
      nvim_cmp = true,
      min_chars = 0,
    },

    picker = {
      name = "telescope.nvim",
    },

    mappings = {
      -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
      ["gf"] = {
        action = function()
          return require("obsidian").util.gf_passthrough()
        end,
        opts = { noremap = false, expr = true, buffer = true },
      },
    },

    notes_subdir = "notes",
    new_notes_location = "notes_subdir",

    templates = {
      folder = "templates"
    },

    -- Optional, customize how note IDs are generated given an optional title.
    ---@param title string|?
    ---@return string
    note_id_func = function(title)
      -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
      -- In this case a note with the title 'My new note' will be given an ID that looks
      -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
      local suffix = ""
      if title ~= nil then
        -- If title is given, transform it into valid file name.
        suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
      else
        -- If title is nil, just add 4 random uppercase letters to the suffix.
        for _ = 1, 4 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
      end
      return tostring(os.time()) .. "-" .. suffix
    end,

    wiki_link_func = "prepend_note_id",

    -- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
    -- URL it will be ignored but you can customize this behavior here.
    ---@param url string
    follow_url_func = function(url)
      -- Open the URL in the default web browser.
      vim.fn.jobstart({ "xdg-open", url })
    end,

    -- Optional, by default when you use `:ObsidianFollowLink` on a link to an image
    -- file it will be ignored but you can customize this behavior here.
    ---@param img string
    follow_img_func = function(img)
      vim.fn.jobstart({ "xdg-open", img })
    end,

    -- Need a callback to set the conceallevel back when a note is re-read due
    -- to edits from the Obsidian app
    ui = {
      enable = false,
      checkboxes = {
        [" "] = { char = " ", hl_group = "ObsidianTodo" },
        ["x"] = { char = "x", hl_group = "ObsidianDone" },
        ["-"] = { char = "-", hl_group = "ObsidianTilde" },
        ["_"] = { char = "_", hl_group = "ObsidianRightArrow" },
      }
    },

    callbacks = {
      enter_note = function(client, note)
        -- When we fix the note re-read thing noted above:
        -- We set the conceallevel in our Markdown ftplugin to avoid the
        -- without disabling all Obsidian.nvim UI features, and then we set it
        -- back to 0 here because the hardcoded conceal behavior around checkbox
        -- lists is ugly as hell, and I'll need to fork the repo to change it.
        -- This workaround is fine for now.
        vim.opt_local.conceallevel = 0

        vim.keymap.set("n", ">>", "<Plug>(bullets-demote)", { buffer = true })
        vim.keymap.set("n", "<<", "<Plug>(bullets-promote)", { buffer = true })
        vim.keymap.set("i", "<c-.>", "<Plug>(bullets-demote)", { buffer = true })
        vim.keymap.set("i", "<c-,>", "<Plug>(bullets-promote)", { buffer = true })

        -- Easily insert date or time
        vim.keymap.set("i", "<c-d>", "<c-r>=strftime('%D')<cr>. ", { buffer = true })
        vim.keymap.set(
          "i", "<c-t>", "<c-r>=substitute(tolower(strftime('%I:%M%p')), '^0', '', '')<cr>. ",
          { buffer = true }
        )

        -- Keymappings for checkbox states
        -- This helper allows us to set vim.go.operatorfunc to a given Lua
        -- function, which in turn enables dot-repeat for that function when
        -- `g@l` is run. Black magic to me, but it works.
        local set_opfunc = vim.fn[vim.api.nvim_exec([[
          func s:set_opfunc(val)
            let &opfunc = a:val
          endfunc
          echon get(function('s:set_opfunc'), 'name')
        ]], true)]

        local checkbox_op = function(cmd)
          return function()
            set_opfunc(function()
              vim.cmd(cmd)
              vim.cmd("set nohlsearch")
            end)
            return "g@l"
          end
        end

        vim.keymap.set("n", "<leader>td", checkbox_op("s/- \\[.\\]/- [x]/"), { expr = true })
        vim.keymap.set("n", "<leader>tu", checkbox_op("s/- \\[.\\]/- [ ]/"), { expr = true })
        vim.keymap.set("n", "<leader>tp", checkbox_op("s/- \\[.\\]/- [-]/"), { expr = true })
        vim.keymap.set("n", "<leader>tc", checkbox_op("s/- \\[.\\]/- [_]/"), { expr = true })
      end
    },

    -- Custom frontmatter handling
    ---@return table
    note_frontmatter_func = function(note)
      -- Remove leading #s from tags so we don't need to confirm completions for
      -- them to just work
      for k, v in pairs(note.tags) do
        if string.sub(v, 1, 1) == "#" then
          note.tags[k] = string.sub(v, 2)
        end
      end

      local out = { id = note.id, tags = note.tags }

      -- `note.metadata` contains any manually added fields in the frontmatter.
      -- So here we just make sure those fields are kept in the frontmatter.
      if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
        for k, v in pairs(note.metadata) do
          out[k] = v
        end
      end

      return out
    end
  },
}
