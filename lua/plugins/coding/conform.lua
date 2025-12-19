-- Conform.nvim: Lightweight formatter plugin with format-on-save support.
-- Runs formatters sequentially and falls back to LSP formatting when needed.
local cfg = require("config.plugins").conform or {}
return {
  "stevearc/conform.nvim",
  enabled = cfg.enabled ~= false,
  branch = cfg.branch,
  event = "BufWritePre",
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "ruff_format" },
      cpp = { "clang-format" },
      c = { "clang-format" },
      rust = { "rustfmt" },
      sh = { "shfmt" },
      bash = { "shfmt" },
      markdown = { "prettier" },
      json = { "prettier" },
      yaml = { "prettier" },
      toml = { "taplo" },
    },
    format_on_save = function()
      if vim.g.disable_autoformat then
        return
      end
      return {
        timeout_ms = 500,
        lsp_format = "fallback",
      }
    end,
  },
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      desc = "Format buffer",
    },
  },
}
