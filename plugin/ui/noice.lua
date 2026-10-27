local plugins = require("config.plugins")
local cfg = plugins.noice or {}
local border = require("utils.ui").border
if cfg.enabled == false then return end

-- Notifications are drawn by snacks.notifier (plugin/ui/snacks.lua), which
-- noice picks as its notify backend when enabled: same border and title
-- style as every other float. <leader>n still lists the history.
require("noice").setup({
	cmdline = {
		enabled = true,
		view = "cmdline_popup",
		-- Prompt icons: Material, like every other pictogram (see utils.ui).
		format = {
			cmdline = { icon = "\u{F07B7}" }, -- md-console_line
			search_down = { icon = "\u{F0349} \u{F0140}" }, -- md-magnify md-chevron_down
			search_up = { icon = "\u{F0349} \u{F0143}" }, -- md-magnify md-chevron_up
			lua = { icon = "\u{F08B1}" }, -- md-language_lua
			help = { icon = "\u{F02D6}" }, -- md-help
			input = { icon = "\u{F03EB}" }, -- md-pencil
		},
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
		-- Progress goes through the notifier like every other message (one
		-- notification per server, updated in place), not the borderless "mini"
		-- view at the bottom right.
		progress = {
			enabled = true,
			view = "notify",
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
		-- The cmdline popup's " Cmdline " / " Search " title on the left, as on
		-- every other float (noice centers it).
		cmdline_popup = { border = { style = border, text = { top_align = require("utils.ui").title_pos } } },
		cmdline_input = { border = { style = border } },
		popup = { border = { style = border } },
		confirm = { border = { style = border } },
		hover = { border = { style = border } },
		-- The cmdline completion popup (:e <Tab>) has no border by default.
		popupmenu = { border = { style = border, padding = { 0, 1 } } },
	},
})

vim.keymap.set("n", "<leader>n", function()
	require("noice").cmd("fzf")
end, { desc = "Notification History" })

vim.keymap.set("n", "<leader>un", function()
	require("noice").cmd("dismiss")
end, { desc = "Dismiss All Notifications" })
