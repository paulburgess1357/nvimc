-- The one look shared by every float, bar and picker: the border, where a
-- float's title sits, the separator glyphs, and the icons for LSP symbol
-- kinds, diagnostic levels and the named side windows. A plugin that draws
-- any of these reads it from here, so a function or an error looks the same
-- in the completion menu (blink), the outline (aerial), the symbols pickers
-- (fzf-lua), the gutter, the statusline and the notifications, and every
-- float has the same frame.

local M = {}

-- Float border for everything: settings.border in config/plugins.lua, which
-- also feeds 'winborder' (config/options.lua) for plugins that read that.
M.border = (require("config.plugins").settings or {}).border or "single"

-- Where a float's title sits in its top border. mini.files, the buffer peek
-- popup and the notifier all put it on the left; fzf-lua defaults to center.
M.title_pos = "left"

-- Blank space inside a float's border, { rows, columns }: one column, no
-- blank rows, in which-key, every noice view and the blink menu (which takes
-- the column count alone). snacks.notifier's default is the same one column;
-- fzf-lua draws no padding of its own.
M.padding = { 0, 1 }

-- Separator between the parts of a label: "Term1 (build) · make", the git
-- blame line, "Quickfix · Grep foo".
M.sep = "·"

-- Separator between the levels of a breadcrumb (the aerial trail in lualine).
M.crumb = "›"

-- Component separator in the statusline: the same bar as the indent guides
-- and the gitsigns column, not an ASCII pipe.
M.bar = "│"

-- Every pictogram in the UI is a Material Design Icons glyph (Nerd Font's
-- nf-md range, U+F0001 up; one set drawn on one grid at one weight): the
-- symbol kinds here, the diagnostics, the side window titles, the dashboard
-- keys, the which-key groups, todo-comments and noice's cmdline prompts.
-- File type icons are nvim-web-devicons' own set and stay that way. Each
-- glyph is written as its codepoint with the icon's name beside it.

-- LSP CompletionItemKind / SymbolKind names -> icon. Shared across plugins;
-- each one ignores the kinds it does not use.
M.kinds = {
	Text = "\u{F027F}", -- md-format_size
	Method = "\u{F0295}", -- md-function
	Function = "\u{F0295}", -- md-function
	Constructor = "\u{F0493}", -- md-cog
	Field = "\u{F0722}", -- md-tag_plus
	Variable = "\u{F01A6}", -- md-cube
	Property = "\u{F05B7}", -- md-wrench
	Class = "\u{F1860}", -- md-format_list_group
	Interface = "\u{F1860}", -- md-format_list_group
	Struct = "\u{F1860}", -- md-format_list_group
	Module = "\u{F0169}", -- md-code_braces
	Namespace = "\u{F0169}", -- md-code_braces
	Package = "\u{F0169}", -- md-code_braces
	Unit = "\u{F0A9A}", -- md-calculator_variant
	Value = "\u{F09A8}", -- md-text
	Enum = "\u{F09A8}", -- md-text
	EnumMember = "\u{F09A8}", -- md-text
	Keyword = "\u{F0EFE}", -- md-identifier
	Constant = "\u{F03FF}", -- md-pi
	Snippet = "\u{F113D}", -- md-text_recognition
	Color = "\u{F03D8}", -- md-palette
	File = "\u{F0214}", -- md-file
	Reference = "\u{F0B32}", -- md-file_replace
	Folder = "\u{F024B}", -- md-folder
	Event = "\u{F140B}", -- md-lightning_bolt
	Operator = "\u{F0A9A}", -- md-calculator_variant
	TypeParameter = "\u{F0B1B}", -- md-alpha_t_box
	String = "\u{F027F}", -- md-format_size
	Number = "\u{F03A0}", -- md-numeric
	Boolean = "\u{F0A19}", -- md-toggle_switch_off_outline
	Array = "\u{F016A}", -- md-code_brackets
	Object = "\u{F0169}", -- md-code_braces
	Key = "\u{F030B}", -- md-key_variant
	Null = "\u{F07E2}", -- md-null
}

-- Diagnostic levels: the gutter signs, the lualine diagnostics component and
-- the glyphs snacks.notifier uses for the same levels.
M.diagnostics = {
	error = "\u{F015A}", -- md-close_circle_outline
	warn = "\u{F002A}", -- md-alert_outline
	info = "\u{F02FD}", -- md-information_outline
	hint = "\u{F0336}", -- md-lightbulb_outline
}

-- Side windows that get a " <icon> <name>" winbar like file windows and
-- terminals (utils.winbar), keyed by filetype. (:LspInfo is a checkhealth
-- window, so it is covered; mason and the dap REPL are not here on purpose:
-- one is a float, the other keeps dap-ui's step controls as its winbar.) `name` is a string or a
-- function (the quickfix window names its list). `hl` colors the icon on
-- the active window, as the devicon color does for a file.
M.windows = {
	aerial = { icon = "\u{F0645}", hl = "Function", name = "Outline" }, -- md-file_tree
	help = { icon = "\u{F02D6}", hl = "String", name = function() return "Help " .. M.sep .. " " .. vim.fn.expand("%:t") end }, -- md-help
	man = { icon = "\u{F05DA}", hl = "String", name = function() return "Man " .. M.sep .. " " .. vim.fn.expand("%:t") end }, -- md-book_open_page_variant
	checkhealth = { icon = "\u{F04D9}", hl = "DiagnosticOk", name = "Health" }, -- md-stethoscope (the dashboard's Health check)
	["gitsigns-blame"] = { icon = "\u{F0718}", hl = "Function", name = "Blame" }, -- md-source_commit
	noice = { icon = "\u{F009C}", hl = "DiagnosticInfo", name = "Notifications" }, -- md-bell_outline (:Noice history)
	qf = {
		icon = "\u{F0756}", -- md-format_list_checks
		hl = "DiagnosticInfo",
		name = function()
			local loclist = vim.fn.win_gettype() == "loclist"
			local info = loclist and vim.fn.getloclist(0, { title = 1 }) or vim.fn.getqflist({ title = 1 })
			local name = loclist and "Location list" or "Quickfix"
			local title = info.title or ""
			-- ":setqflist()" is the title of a list set from Lua, not worth showing.
			if title == "" or title:match("^:%a+list%(%)$") then return name end
			return name .. " " .. M.sep .. " " .. title
		end,
	},
	DiffviewFiles = { icon = "\u{F02A2}", hl = "Function", name = "Diff files" }, -- md-git
	DiffviewFileHistory = { icon = "\u{F02DA}", hl = "Function", name = "File history" }, -- md-history
	-- dap-ui panels; the REPL keeps dap-ui's own winbar with the step controls.
	dapui_scopes = { icon = "\u{F00E4}", hl = "DiagnosticWarn", name = "Scopes" }, -- md-bug
	dapui_breakpoints = { icon = "\u{F00E4}", hl = "DiagnosticWarn", name = "Breakpoints" }, -- md-bug
	dapui_stacks = { icon = "\u{F00E4}", hl = "DiagnosticWarn", name = "Stacks" }, -- md-bug
	dapui_watches = { icon = "\u{F00E4}", hl = "DiagnosticWarn", name = "Watches" }, -- md-bug
	dapui_console = { icon = "\u{F00E4}", hl = "DiagnosticWarn", name = "Console" }, -- md-bug
}

return M
