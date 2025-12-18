-- rainbow-delimiters.nvim: Rainbow coloring for brackets, parentheses, and other delimiters.
-- Uses treesitter for accurate delimiter matching.
local cfg = require("config.plugins").rainbowdelimiters or {}
return {
  "HiPhish/rainbow-delimiters.nvim",
  enabled = cfg.enabled ~= false,
  branch = cfg.branch,
  event = "VeryLazy",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("rainbow-delimiters.setup").setup({
      strategy = {
        [""] = "rainbow-delimiters.strategy.global",
        vim = "rainbow-delimiters.strategy.local",
      },
      query = {
        [""] = "rainbow-delimiters",
        lua = "rainbow-blocks",
      },
      priority = {
        [""] = 110,
        lua = 210,
      },
      highlight = {
        "RainbowDelimiterRed",
        "RainbowDelimiterYellow",
        "RainbowDelimiterBlue",
        "RainbowDelimiterOrange",
        "RainbowDelimiterGreen",
        "RainbowDelimiterViolet",
        "RainbowDelimiterCyan",
      },
    })
  end,
}
