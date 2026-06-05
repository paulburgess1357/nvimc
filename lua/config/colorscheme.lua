local plugins = require("config.plugins")
if (plugins.colorscheme or {}).enabled == false then
	return
end

local theme = (plugins.colorscheme or {}).theme or "onedark"

if theme == "teide" then
	require("teide").setup({
		style = "dark",
		transparent = false,
		terminal_colors = true,
		styles = {
			comments = { italic = true },
		},
	})
	vim.cmd.colorscheme("teide")
elseif theme == "onedark" then
	require("onedark").setup({
		style = "darker",
		transparent = true,
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
			transparent = true,
		},
		diagnostics = {
			darker = true,
			undercurl = true,
			background = true,
		},
	})
	require("onedark").load()
elseif theme == "tokyonight" then
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
elseif theme == "catppuccin" then
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
elseif theme == "kanagawa" then
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
elseif theme == "vscode" then
	require("vscode").setup({
		style = "dark",
		transparent = false,
		italic_comments = true,
		underline_links = true,
		terminal_colors = true,
	})
	vim.cmd.colorscheme("vscode")
elseif theme == "nordic" then
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
end
