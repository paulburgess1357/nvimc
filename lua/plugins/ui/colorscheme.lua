-- Colorscheme configuration
-- Set active_colorscheme to "teide" or "onedark" to switch
local active_colorscheme = "onedark"

return {
	-- Teide: Modern colorscheme with dark, darker, dimmed, and light variants
	{
		"serhez/teide.nvim",
		enabled = active_colorscheme == "teide",
		lazy = false,
		priority = 1000,
		config = function()
			require("teide").setup({
				style = "dark",
				transparent = false,
				terminal_colors = true,
				styles = {
					comments = { italic = true },
				},
			})
			vim.cmd.colorscheme("teide")
		end,
	},

	-- Onedark: Atom-inspired colorscheme with multiple style variants
	{
		"navarasu/onedark.nvim",
		enabled = active_colorscheme == "onedark",
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
	},
}
