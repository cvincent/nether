return {
  "oflisback/obsidian-bridge.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  opts = {
    obsidian_server_address = "http://localhost:27123",
    scroll_sync = true, -- See "Sync of buffer scrolling" section below
    cert_path = nil,    -- See "SSL configuration" section below
    warnings = true,    -- Show misconfiguration warnings
  },
  event = {
    "BufReadPre *.md",
    "BufNewFile *.md",
  },
  lazy = true,
}
