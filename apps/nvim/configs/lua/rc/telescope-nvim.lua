-- if packer_plugins["telescope.nvim"] then
  require("telescope").setup{
    defaults = {
      mappings = {
        i = {
          ["<c-bs>"] = { "<c-s-w>", type = "command" },
          ["<esc>"] = require('telescope.actions').close
        }
      },
      winblend = 28,
      layout_config = {
        width = 0.6;
        height = 0.6;
      }
    }
  }

  -- if packer_plugins["telescope-fzf-native.nvim"] then
    require("telescope").load_extension("fzf")
  -- end


  vim.keymap.set("n", "<c-p>", require("telescope.builtin").find_files)
  vim.keymap.set("n", "<c-f>", require("telescope.builtin").live_grep)
  vim.keymap.set("n", "<leader>gc", require("telescope.builtin").git_branches)
-- end
