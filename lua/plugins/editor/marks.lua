-- marks.nvim: Shows marks in the sign column (lhs) with visual indicators.
local cfg = require("config.plugins").marks or {}
return {
	"chentoast/marks.nvim",
	enabled = cfg.enabled ~= false,
	event = "VeryLazy",
	opts = {
		default_mappings = true,
		signs = true,
		mappings = {},
		excluded_filetypes = {
			"minifiles",
			"lazy",
			"mason",
			"help",
			"snacks_dashboard",
		},
	},
}
