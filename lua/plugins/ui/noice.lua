-- Noice.nvim: Replaces the UI for messages, cmdline, and popupmenu.
-- Provides modern command palette and boxed notifications with level-based colors.
local cfg = require("config.plugins").noice or {}
return {
	"folke/noice.nvim",
	enabled = cfg.enabled ~= false,
	branch = cfg.branch,
	lazy = false,
	dependencies = {
		"MunifTanjim/nui.nvim",
		{
			"rcarriga/nvim-notify",
			opts = {
				stages = "fade",
				timeout = 3000,
				top_down = true,
				render = "wrapped-compact",
			},
		},
	},
	opts = {
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
				view = "mini", -- Shows in bottom right corner
			},
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
			},
			signature = {
				enabled = false, -- blink.cmp handles signatures
			},
		},
		presets = {
			bottom_search = true,
			command_palette = true,
			long_message_to_split = true,
			inc_rename = true, -- Better UI for inc-rename.nvim
			lsp_doc_border = true,
		},
	},
	keys = {
		{
			"<leader>n",
			function()
				require("noice").cmd("fzf")
			end,
			desc = "Notification History",
		},
		{
			"<leader>un",
			function()
				require("noice").cmd("dismiss")
			end,
			desc = "Dismiss All Notifications",
		},
	},
}
