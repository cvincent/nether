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
        -- vim.opt_local.conceallevel = 0

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

        vim.keymap.set("n", "<leader>ft", ":ObsidianTags<cr>")

        -- Set up custom integrations leveraging the Local REST API and Advanced URIs plugins
        local obs_root = "/backup/second-brain"
        local obs_token = vim.env.OBSIDIAN_REST_API_KEY

        local obs_get = function(endpoint)
          local resp = vim.system(
            {
              "curl", "http://localhost:27123/" .. endpoint,
              "-H", "Authorization: Bearer " .. obs_token,
              "-H", "Accept: application/vnd.olrapi.note+json"
            }, { text = true }):wait()
          return vim.json.decode(resp.stdout)
        end
        _G.obs_get = obs_get

        local obs_eval_async = function(script)
          return vim.system(
            { "xdg-open", "obsidian://adv-uri?vault=second-brain&eval=" .. script },
            { text = true }
          )
        end
        _G.obs_eval_async = obs_eval_async

        local obs_eval = function(script)
          local resp = vim.system(
            {
              "curl", "-XPOST", "-d", script,
              "http://localhost:27123/eval",
              "-H", "Authorization: Bearer " .. obs_token,
              "-H", "Accept: application/vnd.olrapi.note+json",
              "-H", "Content-Type: text/plain"
            }, { text = true }):wait()

          return vim.json.decode(resp.stdout)
        end
        _G.obs_eval = obs_eval

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

        local checkbox_op = function(mark)
          return function()
            set_opfunc(function()
              if vim.api.nvim_get_option_value("modified", { buf = 0 }) then
                vim.cmd("w")
                vim.loop.sleep(750)
              end

              local path = vim.fn.expand("%:.")
              local line = vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win())[1]
              local eval =
                  'app.plugins.plugins["obsidian-task-additions"].setCheckboxAtPathLine("' ..
                  path .. '", ' .. line .. ', "' .. mark .. '")'

              obs_eval(eval)
              vim.loop.sleep(250)
              vim.cmd("checktime")
            end)

            vim.api.nvim_feedkeys("g@l", "n", false)
          end
        end

        vim.keymap.set("n", "<leader>td", checkbox_op("x"))
        vim.keymap.set("n", "<leader>tu", checkbox_op(" "))
        vim.keymap.set("n", "<leader>tp", checkbox_op("-"))
        vim.keymap.set("n", "<leader>tc", checkbox_op("_"))

        local obs_open_active = function()
          local filename = obs_root .. "/" .. obs_get("active").path
          vim.cmd("e " .. filename)
        end

        vim.api.nvim_create_user_command("OActive", obs_open_active, {})

        local obs_journal_cmd = function(journal, cmd)
          return function()
            local eval =
                'app.plugins.plugins.journals.manager.journals.get("' .. journal .. '")' ..
                '.execCommand("' .. cmd .. '")'
            -- This will fail with an unhelpful error if Obsidian is not open.
            -- We should do something about that.
            obs_eval(eval)
            obs_open_active()
          end
        end

        vim.api.nvim_create_user_command("OPersonalToday", obs_journal_cmd("personal", "calendar:open-day"), {})
        vim.api.nvim_create_user_command("OPersonalYesterday", obs_journal_cmd("personal", "calendar:open-prev-day"), {})
        vim.api.nvim_create_user_command("OPersonalTomorrow", obs_journal_cmd("personal", "calendar:open-next-day"), {})
        vim.api.nvim_create_user_command("OPersonalWeekly", obs_journal_cmd("personal", "calendar:open-week"), {})

        vim.api.nvim_create_user_command("OWorkToday", obs_journal_cmd("work", "calendar:open-day"), {})
        vim.api.nvim_create_user_command("OWorkYesterday", obs_journal_cmd("work", "calendar:open-prev-day"), {})
        vim.api.nvim_create_user_command("OWorkTomorrow", obs_journal_cmd("work", "calendar:open-next-day"), {})
        vim.api.nvim_create_user_command("OWorkWeekly", obs_journal_cmd("work", "calendar:open-week"), {})

        local jot = function(args, template, startinsert_bang)
          startinsert_bang = startinsert_bang or ""

          -- obs_eval('app.commands.commands["zk-prefixer"].callback()')
          local title = vim.json.encode(args.args)
          local template = vim.json.encode(template)

          local eval = [[
            let templater = app.plugins.plugins["templater-obsidian"].templater
            let file = templater.functions_generator.internal_functions.modules_array.find((m) => m.name == 'file')
            let create_new = file.static_functions.get("create_new")
            let find_tfile = file.static_functions.get("find_tfile")

            create_new(find_tfile($template), $title, true);
          ]]

          obs_eval(eval:gsub("$(%w+)", { title = title, template = template }))
          obs_eval("app.workspace.getActiveFileView().setMode(app.workspace.getActiveFileView().previewMode)")

          local ui = vim.api.nvim_list_uis()[1]
          local filename = obs_root .. "/" .. obs_get("active").path
          local buf = vim.fn.bufadd(filename)

          vim.api.nvim_open_win(buf, true, {
            relative = "editor",
            row = ui.height * 0.33,
            col = ui.width * 0.33,
            width = math.floor(ui.width * 0.33),
            height = math.floor(ui.height * 0.33),
            border = "rounded",
          })

          vim.api.nvim_command("set winblend=10")
          vim.api.nvim_command("normal GA")
          -- vim.api.nvim_command("startinsert" .. startinsert_bang)
          vim.keymap.set("n", "<leader>w", function()
            vim.keymap.del("n", "<leader>w", { buffer = true })
            vim.api.nvim_command("wq!")
          end, { buffer = true })
        end

        vim.api.nvim_create_user_command("OJot", function(args)
          jot(args, "unique-note-templater")
        end, { nargs = 1 })

        vim.api.nvim_create_user_command("OJotTask", function(args)
          jot(args, "unique-note-task-templater", "!")
        end, { nargs = 1 })

        vim.api.nvim_create_user_command("OJotSticky", function(args)
          jot(args, "unique-note-sticky-templater")
        end, { nargs = 1 })
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

      local out = { tags = note.tags }

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
