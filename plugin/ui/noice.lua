local plugins = require("config.plugins")
local cfg = plugins.noice or {}
local ui = require("utils.ui")
local border = ui.border
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
		-- Progress in noice's "mini" view: a borderless line per running task
		-- at the bottom right, redrawn in place. Not the notifier: a long index
		-- (LspIndexAll on a big project) updates ten times a second, and
		-- notifier floats at that rate stutter the editor.
		progress = {
			enabled = true,
			view = "mini",
			-- The finished line's check mark as a Material glyph (see utils.ui).
			format_done = {
				{ "\u{F012C} ", hl_group = "NoiceLspProgressSpinner" }, -- md-check
				{ "{data.progress.title} ", hl_group = "NoiceLspProgressTitle" },
				{ "{data.progress.client} ", hl_group = "NoiceLspProgressClient" },
			},
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
	-- The shared frame on every bordered view: settings.border (noice and its
	-- lsp_doc_border preset default to rounded regardless of 'winborder'),
	-- the title on the left (noice centers the cmdline popup's " Cmdline " /
	-- " Search " and the confirm dialog's " Confirm ") and the one padding
	-- (hover defaults to two columns, the cmdline completion popup to none).
	views = {
		cmdline_popup = { border = { style = border, padding = ui.padding, text = { top_align = ui.title_pos } } },
		cmdline_input = { border = { style = border, padding = ui.padding } },
		popup = { border = { style = border, padding = ui.padding } },
		confirm = { border = { style = border, padding = ui.padding, text = { top_align = ui.title_pos } } },
		hover = { border = { style = border, padding = ui.padding } },
		popupmenu = { border = { style = border, padding = ui.padding } },
	},
})

vim.keymap.set("n", "<leader>n", function()
	require("noice").cmd("fzf")
end, { desc = "Notification history" })

vim.keymap.set("n", "<leader>un", function()
	require("noice").cmd("dismiss")
end, { desc = "Dismiss all notifications" })
