-- if packer_plugins["nvim-dap"] then
  local dap = require("dap")

  dap.adapters.mix_task = {
    type = "executable",
    command = "/home/cvincent/src/estee/elixir-ls/lib/debug_adapter.sh", -- debugger.bat for windows
    args = {}
  }

  dap.configurations.elixir = {
    {
      type = "mix_task",
      name = "phx.server",
      task = "phx.server",
      taskArgs = {"--trace"},
      request = "launch",
      projectDir = "${workspaceFolder}"
    },
  }

  vim.keymap.set("n", "<leader>db", ":lua require'dap'.toggle_breakpoint()<cr>")
  vim.keymap.set("n", "<leader>dc", ":lua require'dap'.continue()<cr>")
  vim.keymap.set("n", "<leader>dso", ":lua require'dap'.step_over()<cr>")
  vim.keymap.set("n", "<leader>dsi", ":lua require'dap'.step_into()<cr>")
  vim.keymap.set("n", "<leader>dr", ":lua require'dap'.open()<cr>")
-- end
