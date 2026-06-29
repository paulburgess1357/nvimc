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
	local transparent = true

	-- onedark ships highlight groups for most plugins, but it has two gaps
	-- relative to meowsoot: (1) `transparent` only blanks the main editor, not
	-- floats/pickers, and (2) it has no fzf-lua groups at all. Patch both via
	-- the built-in `highlights` override ($name = palette color, applied last).
	local highlights = {
		-- Transparent cursorline (slab removed in the loop below); keep the
		-- row visible via a bold, accented line number instead of a bg slab.
		CursorLineNr = { fg = "$orange", fmt = "bold" },

		-- fzf-lua (onedark has no native support)
		FzfLuaNormal = { bg = transparent and "none" or "$bg_d" },
		FzfLuaBorder = { fg = "$cyan", bg = transparent and "none" or "$bg_d" },
		FzfLuaTitle = { fg = "$red", fmt = "bold" },
		FzfLuaPreviewNormal = { bg = transparent and "none" or "$bg_d" },
		FzfLuaPreviewBorder = { fg = "$cyan", bg = transparent and "none" or "$bg_d" },
		FzfLuaPreviewTitle = { fg = "$red", fmt = "bold" },
		FzfLuaCursorLine = { bg = "$bg2" },
		FzfLuaFzfMatch = { fg = "$orange", fmt = "bold" },
		FzfLuaHeaderText = { fg = "$purple" },
		FzfLuaHeaderBind = { fg = "$blue" },
		FzfLuaPathColNr = { fg = "$cyan" },
		FzfLuaPathLineNr = { fg = "$green" },
		FzfLuaBufNr = { fg = "$yellow" },
		FzfLuaBufName = { fg = "$blue" },
		FzfLuaTabTitle = { fg = "$cyan", fmt = "bold" },
		FzfLuaLiveSym = { fg = "$orange" },
	}

	if transparent then
		-- Make every floating window / popup honor transparency. onedark bakes
		-- these as solid bg (bg1/bg_d), so override their backgrounds to none.
		for _, g in ipairs({
			"CursorLine",
			"StatusLine",
			"StatusLineNC",
			"TabLine",
			"TabLineFill",
			"TabLineSel",
			"NormalFloat",
			"FloatBorder",
			"Pmenu",
			"PmenuSbar",
			"PmenuThumb",
			"MiniFilesNormal",
			"MiniFilesBorder",
			"MiniPickNormal",
			"MiniPickBorder",
			"MiniNotifyNormal",
			"MiniNotifyBorder",
			"SnacksPicker",
			"SnacksPickerBorder",
			"TelescopeNormal",
			"TelescopeBorder",
			"NoiceCmdlinePopup",
			"NoiceCmdlinePopupBorder",
			"NoicePopup",
			"NoicePopupBorder",
			"BlinkCmpMenu",
			"BlinkCmpMenuBorder",
			"BlinkCmpDoc",
			"BlinkCmpDocBorder",
			"BlinkCmpSignatureHelp",
			"WhichKeyFloat",
		}) do
			highlights[g] = { bg = "none" }
		end
	end

	require("onedark").setup({
		style = "darker",
		transparent = transparent,
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
			transparent = transparent,
		},
		diagnostics = {
			darker = true,
			undercurl = true,
			background = true,
		},
		highlights = highlights,
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
elseif theme == "meowsoot" then
	require("meowsoot").setup({
		style = "night",
		transparent = true,
		terminal_colors = true,
		styles = {
			comments = { italic = true },
			keywords = {},
			functions = {},
			variables = {},
			sidebars = "transparent",
			floats = "transparent",
		},
		plugins = {
			all = false,
			auto = true,
		},
		cache = true,
	})
	vim.cmd.colorscheme("meowsoot")
end
