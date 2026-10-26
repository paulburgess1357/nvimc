-- One icon set for everything that names an LSP symbol kind or a diagnostic
-- level, so a function or an error looks the same in the completion menu
-- (blink), the outline (aerial), the symbols pickers (fzf-lua), the gutter
-- and the notifications (snacks uses the same diagnostic glyphs).

local M = {}

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

-- Diagnostic levels, the glyphs snacks.notifier uses for the same levels.
M.diagnostics = {
	error = "\u{F057}", -- 
	warn = "\u{F071}", -- 
	info = "\u{F05A}", -- 
	hint = "\u{F059}", -- 
}

return M
