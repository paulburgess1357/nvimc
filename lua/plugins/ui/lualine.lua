-- Lualine.nvim: Fast and customizable statusline written in Lua.
-- Displays mode, git branch, diagnostics, and file info with minimal overhead.
local cfg = require("config.plugins").lualine or {}
return {
  "nvim-lualine/lualine.nvim",
  enabled = cfg.enabled ~= false,
  branch = cfg.branch,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "SmiteshP/nvim-navic",
  },
  opts = {
    options = {
      theme = "auto",
      icons_enabled = true,
      component_separators = { left = "|", right = "|" },
      section_separators = { left = "", right = "" },
      globalstatus = true,
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", "diff", "diagnostics" },
      lualine_c = {
        "filename",
        {
          "navic",
          color_correction = "static",
        },
      },
      lualine_x = { "encoding", "fileformat", "filetype" },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
    tabline = {
      lualine_a = {
        {
          "buffers",
          show_filename_only = true,
          show_modified_status = true,
          mode = 0,
          symbols = {
            modified = " ●",
          },
        },
      },
    },
  },
}
