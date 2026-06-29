local plugins = require("config.plugins")
if (plugins.colorscheme or {}).enabled == false then
	return
end

local theme = (plugins.colorscheme or {}).theme or "onedark"

-- Only onedark is wired up. To add another theme: register its repo in the
-- `colorscheme_specs` table in init.lua, then add an `elseif theme == "name"`
-- branch below with its setup() call.
if theme == "onedark" then
	local transparent = true

	-- onedark ships highlight groups for most plugins, but it has two gaps:
	-- (1) `transparent` only blanks the main editor, not floats/pickers, and
	-- (2) it has no fzf-lua groups at all. Patch both via the built-in
	-- `highlights` override ($name = palette color, applied last).
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
else
	vim.notify(
		('colorscheme: theme "%s" is not configured in colorscheme.lua'):format(theme),
		vim.log.levels.WARN
	)
end
