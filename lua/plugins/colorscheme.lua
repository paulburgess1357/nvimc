-- Colorscheme plugin
return {
  "navarasu/onedark.nvim",
  priority = 1000,
  config = function()
    require("onedark").setup({
      style = "warmer",
      transparent = false,
      term_colors = true,
      ending_tildes = false,
      toggle_style_key = "<leader>ts",
      toggle_style_list = { "dark", "darker", "cool", "deep", "warm", "warmer", "light" },
      code_style = {
        comments = "italic",
        keywords = "none",
        functions = "none",
        strings = "none",
        variables = "none",
      },
      lualine = {
        transparent = false,
      },
      diagnostics = {
        darker = true,
        undercurl = true,
        background = true,
      },
    })
    require("onedark").load()
  end,
}
