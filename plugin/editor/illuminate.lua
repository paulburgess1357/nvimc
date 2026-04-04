local plugins = require("config.plugins")
local cfg = plugins.illuminate or {}
local settings = plugins.settings or {}
if cfg.enabled == false then return end

require("illuminate").configure({
	delay = 100,
	large_file_cutoff = settings.illuminate_max_lines,
	under_cursor = true,
	providers = {
		"lsp",
		"treesitter",
		"regex",
	},
	filetypes_denylist = {
		"dirbuf", "dirvish", "fugitive", "alpha", "NvimTree",
		"neo-tree", "minifiles", "dashboard", "TelescopePrompt",
		"lazy", "mason",
	},
	min_count_to_highlight = 1,
})

vim.keymap.set("n", "]]", function()
	require("illuminate").goto_next_reference(false)
end, { desc = "Next Reference" })

vim.keymap.set("n", "[[", function()
	require("illuminate").goto_prev_reference(false)
end, { desc = "Prev Reference" })
