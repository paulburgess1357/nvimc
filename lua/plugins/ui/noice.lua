-- Noice.nvim: Replaces the UI for messages, cmdline, and popupmenu.
-- Provides a modern command palette and improved notification experience.
local cfg = require("config.plugins").noice or {}
return {
  "folke/noice.nvim",
  enabled = cfg.enabled ~= false,
  branch = cfg.branch,
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  opts = {
    lsp = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
      },
      signature = {
        enabled = false, -- blink.cmp handles signatures
      },
    },
    cmdline = {
      enabled = true,
      view = "cmdline_popup",
    },
    popupmenu = {
      enabled = true,
      backend = "nui",
    },
    messages = {
      enabled = true,
    },
    presets = {
      bottom_search = true,
      command_palette = true,
      long_message_to_split = true,
      lsp_doc_border = true,
    },
  },
}
