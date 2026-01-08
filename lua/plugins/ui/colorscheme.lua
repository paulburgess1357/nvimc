-- Colorscheme configuration
-- Set active_colorscheme to "teide", "onedark", "tokyonight", "catppuccin", "kanagawa", "vscode", or "nordic" to switch
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

	-- Tokyonight: Clean dark theme with moon, storm, night, and day variants
	{
		"folke/tokyonight.nvim",
		enabled = active_colorscheme == "tokyonight",
		lazy = false,
		priority = 1000,
		config = function()
			require("tokyonight").setup({
				style = "moon",
				transparent = false,
				terminal_colors = true,
				styles = {
					comments = { italic = true },
					keywords = {},
					functions = {},
					variables = {},
					sidebars = "dark",
					floats = "dark",
				},
				dim_inactive = false,
			})
			vim.cmd.colorscheme("tokyonight")
		end,
	},

	-- Catppuccin: Soothing pastel theme with latte, frappe, macchiato, and mocha variants
	{
		"catppuccin/nvim",
		name = "catppuccin",
		enabled = active_colorscheme == "catppuccin",
		lazy = false,
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "mocha",
				transparent_background = false,
				term_colors = true,
				styles = {
					comments = { "italic" },
					conditionals = {},
					loops = {},
					functions = {},
					keywords = {},
					strings = {},
					variables = {},
					numbers = {},
					booleans = {},
					properties = {},
					types = {},
					operators = {},
				},
			})
			vim.cmd.colorscheme("catppuccin")
		end,
	},

	-- Kanagawa: Japanese-inspired theme with wave, dragon, and lotus variants
	{
		"rebelot/kanagawa.nvim",
		enabled = active_colorscheme == "kanagawa",
		lazy = false,
		priority = 1000,
		config = function()
			require("kanagawa").setup({
				transparent = false,
				terminalColors = true,
				dimInactive = false,
				commentStyle = { italic = true },
				functionStyle = {},
				keywordStyle = {},
				statementStyle = {},
				typeStyle = {},
				background = {
					dark = "dragon",
					light = "lotus",
				},
			})
			vim.cmd.colorscheme("kanagawa")
		end,
	},

	-- VSCode: Dark+ and Light+ inspired theme
	{
		"Mofiqul/vscode.nvim",
		enabled = active_colorscheme == "vscode",
		lazy = false,
		priority = 1000,
		config = function()
			require("vscode").setup({
				style = "dark",
				transparent = false,
				italic_comments = true,
				underline_links = true,
				terminal_colors = true,
			})
			vim.cmd.colorscheme("vscode")
		end,
	},

	-- Nordic: Nord-inspired theme with reduced blue tones
	{
		"AlexvZyl/nordic.nvim",
		enabled = active_colorscheme == "nordic",
		lazy = false,
		priority = 1000,
		config = function()
			require("nordic").setup({
				transparent = {
					bg = false,
					float = false,
				},
				italic_comments = true,
				bold_keywords = false,
				reduced_blue = true,
				cursorline = {
					theme = "dark",
				},
			})
			require("nordic").load()
		end,
	},
}
