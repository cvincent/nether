return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",

    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },

    config = function()
      -- TODO: The following is imperative, and anyways install_info won't work
      -- when we eventually upgrade to NeoVim 0.12 and switch nvim-treesitter to
      -- the `main` branch. This is temporary just to get things working.
      -- Ultimately we'll probably do this stuff in nvf or whatever we end up
      -- using.
      require("nvim-treesitter.parsers").get_parser_configs().heex.install_info = {
        url = "~/src/tree-sitter-heex",
        files = { "src/parser.c", "src/scanner.c" },
      }

      -- TODO: Put this in its own file.
      vim.treesitter.query.set("heex", "injections", [[
        (directive
          [ (partial_expression_value) (ending_expression_value) ] @injection.content
          (#set! injection.language "elixir")
          (#set! injection.include-children)
          (#set! injection.combined))
        ((directive (expression_value) @injection.content) (#set! injection.language "elixir"))
        (expression (expression_value) @injection.content (#set! injection.language "elixir"))
        ((comment) @injection.content (#set! injection.language "comment"))

        ((tag (start_tag (tag_name) @_tag) (raw_text) @injection.content)
          (#eq? @_tag "script") (#set! injection.language "javascript"))
        ((tag (start_tag (tag_name) @_tag) (raw_text) @injection.content)
          (#eq? @_tag "style")  (#set! injection.language "css"))
      ]])

      local opts = {
        auto_install = true,

        ensure_installed = { "elixir" },

        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },

        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
          },
        },

        indent = {
          enable = true,

          -- NOTE: This takes the parser names, _not_ the filetypes
          disable = {
            -- Treesitter indent doesn't handle list continuations well
            "markdown",
            -- Works poorly in general in Nix files
            "nix",
          }
        },

        textobjects = {
          select = {
            enable = true,

            keymaps = {
              ["ia"] = "@parameter.inner",
              ["aa"] = "@parameter.outer",
              ["im"] = "@function.inner",
              ["am"] = "@function.outer",
            },

            selection_modes = {
              ["@function.inner"] = "V",
              ["@function.outer"] = "V",
            },
          },

          swap = {
            enable = true,

            swap_next = {
              ["<leader>xa"] = "@parameter.inner", -- swap parameters/argument with next
              ["<leader>xm"] = "@function.outer",  -- swap function with next
            },

            swap_previous = {
              ["<leader>xA"] = "@parameter.inner", -- swap parameters/argument with prev
              ["<leader>xM"] = "@function.outer",  -- swap function with previous
            },
          },

          move = {
            enable = true,
            set_jumps = true,

            goto_next_start = {
              ["]a"] = "@parameter.outer",
              ["]m"] = "@function.outer",
            },

            goto_previous_start = {
              ["[a"] = "@parameter.outer",
              ["[m"] = "@function.outer",
            },
          },
        },
      }

      require("nvim-treesitter.configs").setup(opts)
    end,

    init = function()
      vim.wo.foldmethod = "expr"
      vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"

      local show_ts_node = function()
        vim.cmd("TSNodeUnderCursor")
        vim.print(vim.treesitter.get_node():type())
      end

      vim.keymap.set("n", "<c-s-t>", show_ts_node)
      vim.keymap.set("i", "<c-s-t>", show_ts_node)
    end
  },

  "nvim-treesitter/playground",

  {
    "nvim-treesitter/nvim-treesitter-context",

    opts = {
      enable = false,
      multiline_threshold = 1,
    },
  },
}
