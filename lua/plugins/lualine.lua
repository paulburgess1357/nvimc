-- Lualine: Fast and customizable statusline
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
      refresh = {
        statusline = 100,
        tabline = 100,
        winbar = 100,
      },
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
    winbar = {
      lualine_z = {
        {
          "filename",
          path = 3, -- Absolute path
        },
      },
    },
    inactive_winbar = {
      lualine_z = {
        {
          "filename",
          path = 3,
        },
      },
    },
  },
}
