return {
  "mfussenegger/nvim-dap",
  config = function()
    local dap = require("dap")

    dap.adapters.mix_task = {
      type = "executable",
      command = "/nix/store/aank5w3p836gw8grkj4dnh339q1yfz6g-elixir-ls-0.18.1/lib/debug_adapter.sh",
      args = {}
    }

    dap.configurations.elixir = {
      {
        type = "mix_task",
        task = "phx.server",
        -- taskArgs = {"--trace"}, this is only for mix test
        request = "launch",
      },
    }

    vim.keymap.set("n", "<leader>db", ":lua require'dap'.toggle_breakpoint()<cr>")
    vim.keymap.set("n", "<leader>dc", ":lua require'dap'.continue()<cr>")
    vim.keymap.set("n", "<leader>dso", ":lua require'dap'.step_over()<cr>")
    vim.keymap.set("n", "<leader>dsi", ":lua require'dap'.step_into()<cr>")
    vim.keymap.set("n", "<leader>dr", ":lua require'dap'.open()<cr>")
  end,
}
