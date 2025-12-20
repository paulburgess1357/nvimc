-- nvim-scrollview: Displays scrollbar with diagnostic/search/mark indicators.
local cfg = require("config.plugins").scrollview or {}
return {
	"dstein64/nvim-scrollview",
	enabled = cfg.enabled ~= false,
	branch = cfg.branch,
	event = "VeryLazy",
	opts = {
		visibility = "always",
		current_only = true,
		signs_on_startup = { "diagnostics", "search", "marks", "keywords", "changelist" },
		diagnostics_error_symbol = "●",
		diagnostics_warn_symbol = "●",
		diagnostics_info_symbol = "●",
		diagnostics_hint_symbol = "●",
		excluded_filetypes = {
			"minifiles",
			"lazy",
			"mason",
			"help",
			"snacks_dashboard",
		},
	},
}
