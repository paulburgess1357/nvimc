local cfg = require("config.plugins").noice or {}
if cfg.enabled == false then return end

require("notify").setup({
	stages = "fade",
	timeout = 3000,
	top_down = true,
	render = "compact",
	-- Under a transparent theme `NotifyBackground` has no bg, so notify can't
	-- compute its fade blend. This hex is only the blend reference for the fade
	-- (not a visible bg); black matches the dark backdrop.
	background_colour = "#000000",
})

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
})

vim.keymap.set("n", "<leader>n", function()
	require("noice").cmd("fzf")
end, { desc = "Notification History" })

vim.keymap.set("n", "<leader>un", function()
	require("noice").cmd("dismiss")
end, { desc = "Dismiss All Notifications" })
