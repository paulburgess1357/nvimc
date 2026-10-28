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
		"mason",
	},
	min_count_to_highlight = 1,
})

-- References are lit only in the active window: illuminate refreshes on
-- cursor movement but never clears when the cursor leaves, so a buffer kept
-- its highlights while another window was active. Cleared on leaving,
-- refreshed on entering (entering alone moves no cursor).
local group = vim.api.nvim_create_augroup("illuminate_active_window", { clear = true })
vim.api.nvim_create_autocmd("WinLeave", {
	group = group,
	callback = function(ev)
		require("illuminate.highlight").buf_clear_references(ev.buf)
		require("illuminate.reference").buf_set_references(ev.buf, {})
	end,
})
vim.api.nvim_create_autocmd("WinEnter", {
	group = group,
	callback = function() require("illuminate.engine").refresh_references() end,
})

vim.keymap.set("n", "]]", function()
	require("illuminate").goto_next_reference(false)
end, { desc = "Next reference" })

vim.keymap.set("n", "[[", function()
	require("illuminate").goto_prev_reference(false)
end, { desc = "Previous reference" })
