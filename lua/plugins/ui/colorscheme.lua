-- Onedark.nvim: Atom-inspired colorscheme with multiple style variants.
-- Supports 7 styles (dark, darker, cool, deep, warm, warmer, light) and treesitter.
local cfg = require("config.plugins").colorscheme or {}

return {
	"navarasu/onedark.nvim",
	enabled = cfg.enabled ~= false,
	branch = cfg.branch,
	lazy = false,
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
