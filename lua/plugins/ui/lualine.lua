-- Lualine.nvim: Fast and customizable statusline written in Lua.
-- Displays mode, git branch, diagnostics, and file info with minimal overhead.
return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "SmiteshP/nvim-navic",
  },
  opts = {
    options = {
      theme = "onedark",
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
  },
}
