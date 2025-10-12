return {
  "tpope/vim-rails",

  init = function()
    local augroup = vim.api.nvim_create_augroup("rails.init", { clear = true })

    vim.api.nvim_create_autocmd("User", {
      pattern = "Rails",
      group = augroup,
      callback = function()
        local path = vim.api.nvim_eval("rails#buffer().relative()")
        local type = vim.api.nvim_eval("rails#buffer().type_name()")

        local app_relative_path = path:gsub("^app/", ""):gsub("%.rb$", "")
        local is_spec = string.match(type, "^spec-") ~= nil

        local open_styles = { "E", "S", "V", "T" }

        for _, open_style in ipairs(open_styles) do
          local downcase = string.lower(open_style)
          vim.keymap.set("n", "<leader>r" .. downcase .. "a", function()
            vim.cmd("A" .. open_style)
          end, { buffer = true })
        end

        local open_or_generate_spec = function(open_style)
          local cmd = open_style .. "spec "

          if not pcall(vim.cmd, cmd .. app_relative_path) then
            vim.cmd(cmd .. app_relative_path .. "!")
          end
        end

        if not is_spec then
          for _, open_style in ipairs(open_styles) do
            local downcase = string.lower(open_style)
            vim.keymap.set("n", "<leader>r" .. downcase .. "s", function()
              open_or_generate_spec(open_style)
            end, { buffer = true })
          end
        end

        if type == "controller" then
          for _, open_style in ipairs(open_styles) do
            local downcase = string.lower(open_style)
            vim.keymap.set("n", "<leader>r" .. downcase .. "v", function()
              vim.cmd(open_style .. "view")
            end, { buffer = true })
          end
        end
      end
    })
  end
}
