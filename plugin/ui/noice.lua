local plugins = require("config.plugins")
local cfg = plugins.noice or {}
local border = (plugins.settings or {}).border or "single"
if cfg.enabled == false then return end

-- Notifications are drawn by snacks.notifier (plugin/ui/snacks.lua), which
-- noice picks as its notify backend when enabled: same border and title
-- style as every other float. <leader>n still lists the history.
require("noice").setup({
	cmdline = {
		enabled = true,
		view = "cmdline_popup",
	},
	messages = {
		enabled = true,
	},
	popupmenu = {
		enabled = true,
		backend = "nui",
	},
	notify = {
		enabled = true,
	},
	lsp = {
		progress = {
			enabled = true,
			view = "mini",
		},
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
		},
		signature = {
			enabled = false,
		},
	},
	presets = {
		bottom_search = true,
		command_palette = true,
		long_message_to_split = true,
		inc_rename = true,
		lsp_doc_border = true,
	},
	-- settings.border on every bordered view (noice and its lsp_doc_border
	-- preset default to rounded regardless of 'winborder').
	views = {
		cmdline_popup = { border = { style = border } },
		cmdline_input = { border = { style = border } },
		popup = { border = { style = border } },
		confirm = { border = { style = border } },
		hover = { border = { style = border } },
	},
})

vim.keymap.set("n", "<leader>n", function()
	require("noice").cmd("fzf")
end, { desc = "Notification History" })

vim.keymap.set("n", "<leader>un", function()
	require("noice").cmd("dismiss")
end, { desc = "Dismiss All Notifications" })
