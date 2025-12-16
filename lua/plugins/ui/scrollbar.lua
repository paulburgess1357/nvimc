-- Satellite.nvim: Decorative scrollbar with diagnostic and git integration.
-- Shows cursor position, search results, diagnostics, and git changes in the scrollbar.
return {
  "lewis6991/satellite.nvim",
  event = "VeryLazy",
  opts = {
    current_only = false,
    winblend = 50,
    zindex = 40,
    excluded_filetypes = {
      "prompt",
      "TelescopePrompt",
      "noice",
      "notify",
      "neo-tree",
      "minifiles",
      "dashboard",
      "lazy",
      "mason",
    },
    handlers = {
      cursor = {
        enable = true,
        symbols = { "⎺", "⎻", "⎼", "⎽" },
      },
      search = {
        enable = true,
      },
      diagnostic = {
        enable = true,
        signs = { "-", "=", "≡" },
        min_severity = vim.diagnostic.severity.HINT,
      },
      gitsigns = {
        enable = true,
        signs = {
          add = "│",
          change = "│",
          delete = "-",
        },
      },
      marks = {
        enable = true,
        show_builtins = false,
      },
      quickfix = {
        enable = true,
      },
    },
  },
}
