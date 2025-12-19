-- marks.nvim: Display marks in the sign column with visual indicators.
-- Shows lowercase/uppercase marks and provides quick navigation between them.
local cfg = require("config.plugins").marks or {}
return {
	"chentoast/marks.nvim",
	enabled = cfg.enabled ~= false,
	branch = cfg.branch,
	event = "VeryLazy",
	opts = {
		default_mappings = true,
		signs = true,
		cyclic = true,
		refresh_interval = 250,
		sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
	},
}
