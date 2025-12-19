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
  opts = function()
    local normal_hl = vim.api.nvim_get_hl(0, { name = "Normal" })
    local normal_bg = normal_hl.bg and string.format("#%06x", normal_hl.bg) or nil
    local custom_theme = require("lualine.themes.auto")
    -- Set tabline background to match Normal
    if normal_bg then
      for _, mode in pairs(custom_theme) do
        if mode.c then
          mode.c.bg = normal_bg
        end
      end
    end
    return {
      options = {
        theme = custom_theme,
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
      lualine_a = {},
      lualine_b = {},
      lualine_c = {
        {
          "buffers",
          show_filename_only = true,
          show_modified_status = true,
          mode = 0,
          symbols = {
            modified = " ●",
            alternate_file = "",
          },
        },
      },
      lualine_x = {},
      lualine_y = {},
      lualine_z = {},
    },
  }
  end,
}
