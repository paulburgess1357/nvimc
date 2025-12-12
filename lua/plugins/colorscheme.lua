-- Colorscheme plugin
return {
  "olimorris/onedarkpro.nvim",
  priority = 1000,
  opts = {
    -- Styling options for syntax elements
    -- Available styles: "NONE", "italic", "bold", "underline", "undercurl"
    styles = {
      types = "NONE",
      methods = "NONE",
      numbers = "NONE",
      strings = "NONE",
      comments = "italic",
      keywords = "NONE",
      constants = "NONE",
      functions = "NONE",
      operators = "NONE",
      variables = "NONE",
      parameters = "NONE",
      conditionals = "NONE",
      virtual_text = "NONE",
    },

    options = {
      cursorline = false,              -- Highlight current line
      transparency = false,             -- Transparent background
      terminal_colors = true,           -- Set terminal colors
      lualine_transparency = false,     -- Transparent statusline
      highlight_inactive_windows = false, -- Dim inactive windows
      lsp_semantic_tokens = true,       -- Enable LSP semantic tokens (member vars vs local vars)
    },

    -- Override default colors (optional)
    -- colors = {},

    -- Override highlight groups (optional)
    -- highlights = {},
  },
  config = function(_, opts)
    require("onedarkpro").setup(opts)
    -- Available themes: onedark, onelight, onedark_vivid, onedark_dark
    vim.cmd.colorscheme("onedark")
  end,
}
