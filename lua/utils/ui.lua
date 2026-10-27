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

-- Separator between the parts of a label: "Term1 (build) · make", the git
-- blame line, "Quickfix · Grep foo".
M.sep = "·"

-- Separator between the levels of a breadcrumb (the aerial trail in lualine).
M.crumb = "›"

-- Component separator in the statusline: the same bar as the indent guides
-- and the gitsigns column, not an ASCII pipe.
M.bar = "│"

-- LSP CompletionItemKind / SymbolKind names -> icon. Shared across plugins;
-- each one ignores the kinds it does not use.
M.kinds = {
	Text = "󰉿",
	Method = "󰊕",
	Function = "󰊕",
	Constructor = "󰒓",
	Field = "󰜢",
	Variable = "󰆦",
	Property = "󰖷",
	Class = "󱡠",
	Interface = "󱡠",
	Struct = "󱡠",
	Module = "󰅩",
	Namespace = "󰅩",
	Package = "󰅩",
	Unit = "󰪚",
	Value = "󰦨",
	Enum = "󰦨",
	EnumMember = "󰦨",
	Keyword = "󰻾",
	Constant = "󰏿",
	Snippet = "󱄽",
	Color = "󰏘",
	File = "󰈔",
	Reference = "󰬲",
	Folder = "󰉋",
	Event = "󱐋",
	Operator = "󰪚",
	TypeParameter = "󰬛",
	String = "󰉿",
	Number = "󰎠",
	Boolean = "󰨙",
	Array = "󰅪",
	Object = "󰅩",
	Key = "󰌋",
	Null = "󰟢",
}

-- Diagnostic levels: the gutter signs, the lualine diagnostics component and
-- the glyphs snacks.notifier uses for the same levels.
M.diagnostics = {
	error = "\u{F057}", --
	warn = "\u{F071}", --
	info = "\u{F05A}", --
	hint = "\u{F059}", --
}

-- Side windows that get a " <icon> <name>" winbar like file windows and
-- terminals (utils.winbar), keyed by filetype. `name` is a string or a
-- function (the quickfix window names its list). `hl` colors the icon on
-- the active window, as the devicon color does for a file.
M.windows = {
	aerial = { icon = "󰙅", hl = "Function", name = "Outline" },
	help = { icon = "󰋖", hl = "String", name = function() return "Help " .. M.sep .. " " .. vim.fn.expand("%:t") end },
	qf = {
		icon = "󰁨",
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
	DiffviewFiles = { icon = "", hl = "Function", name = "Diff files" },
	DiffviewFileHistory = { icon = "", hl = "Function", name = "File history" },
	-- dap-ui panels; the REPL keeps dap-ui's own winbar with the step controls.
	dapui_scopes = { icon = "", hl = "DiagnosticWarn", name = "Scopes" },
	dapui_breakpoints = { icon = "", hl = "DiagnosticWarn", name = "Breakpoints" },
	dapui_stacks = { icon = "", hl = "DiagnosticWarn", name = "Stacks" },
	dapui_watches = { icon = "", hl = "DiagnosticWarn", name = "Watches" },
	dapui_console = { icon = "", hl = "DiagnosticWarn", name = "Console" },
}

return M
