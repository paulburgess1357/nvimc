return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  opts = {
    lsp = {
      -- Override markdown rendering so that cmp and other plugins use Treesitter
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
    },
    -- Command line popup
    cmdline = {
      enabled = true,
      view = "cmdline_popup",
    },
    -- Popupmenu for command completions
    popupmenu = {
      enabled = true,
      backend = "nui",
    },
    -- Message notifications
    messages = {
      enabled = true,
    },
    -- Presets
    presets = {
      bottom_search = true,
      command_palette = true,
      long_message_to_split = true,
    },
  },
}
