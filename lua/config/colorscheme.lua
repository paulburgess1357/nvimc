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
		-- Transparent cursorline (slab removed in the loop below); the row is
		-- marked by a bold line number in the mode color instead (CursorLineNr,
		-- set by mode_accents at the bottom of this file).

		-- Split separators in the same grey as the float borders (onedark
		-- draws them in bg3, which all but vanishes on a transparent
		-- background), so panes and floats are framed by one line color.
		WinSeparator = { fg = "$grey" },

		-- One look for every float: grey border (onedark's FloatBorder), cyan
		-- bold title (mini.files' focused title), and a $bg2 slab on the
		-- selected row (mini.files' cursor line). Applied to fzf-lua, blink,
		-- noice/which-key (FloatTitle, PmenuSel) and snacks below.
		FloatTitle = { fg = "$cyan", fmt = "bold" },
		PmenuSel = { fg = "none", bg = "$bg2" },
		BlinkCmpMenuSelection = { bg = "$bg2" },
		SnacksPickerTitle = { fg = "$cyan", fmt = "bold" },

		-- Closed folds (utils.folds): the "▸ N lines" marker after the fold line.
		FoldedCount = { fg = "$orange", fmt = "bold" },

		-- treesitter-context: no slab (transparent like everything else), a
		-- grey rule under the pinned lines marks where the context ends.
		TreesitterContextSeparator = { fg = "$grey" },
		TreesitterContextLineNumber = { fg = "$grey" },

		-- fzf-lua (onedark has no native support)
		FzfLuaNormal = { bg = transparent and "none" or "$bg_d" },
		FzfLuaBorder = { fg = "$grey", bg = transparent and "none" or "$bg_d" },
		FzfLuaTitle = { fg = "$cyan", fmt = "bold" },
		FzfLuaPreviewNormal = { bg = transparent and "none" or "$bg_d" },
		FzfLuaPreviewBorder = { fg = "$grey", bg = transparent and "none" or "$bg_d" },
		FzfLuaPreviewTitle = { fg = "$cyan", fmt = "bold" },
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
			-- terminal windows remap StatusLine -> StatusLineTerm via winhighlight
			"StatusLineTerm",
			"StatusLineTermNC",
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
			"TreesitterContext",
			"TreesitterContextLineNumber",
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
	vim.notify(('colorscheme: theme "%s" is not configured in colorscheme.lua'):format(theme), vim.log.levels.WARN)
end

-----------------------------------------------------------
-- Mode-colored accents. The current line number, the snacks indent scope
-- guide and the current entry in winbars / the buffer peek popup
-- (LualineBufActive, used by utils.winbar, utils.terms, utils.buftabs) take
-- the same color as the mode pill at the bottom left of the statusline
-- (green in normal, blue in insert, ...), so they all agree on what mode
-- you are in. The color is lualine's theme.a for the mode, read from its
-- `auto` theme (derived from this colorscheme), using lualine's own mode ->
-- theme-section mapping; modes the theme doesn't define (terminal, command)
-- fall back to normal, as lualine does. Works whether or not lualine is
-- enabled, as long as it is installed.
-----------------------------------------------------------
local function mode_accents()
	local ok, hl = pcall(require, "lualine.highlight")
	if not ok then return end
	local theme = require("lualine.themes.auto")
	local section = hl.get_mode_suffix():sub(2)
	local a = (theme[section] or theme.normal or {}).a
	if not (a and a.bg) then return end
	vim.api.nvim_set_hl(0, "CursorLineNr", { fg = a.bg, bold = true })
	vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = a.bg })
	vim.api.nvim_set_hl(0, "LualineBufActive", { fg = a.bg, bold = true })
end
vim.api.nvim_create_autocmd({ "ModeChanged", "ColorScheme" }, {
	group = vim.api.nvim_create_augroup("mode_accents", { clear = true }),
	callback = mode_accents,
})
mode_accents()
