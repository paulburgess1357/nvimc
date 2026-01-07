-- Hardtime.nvim: Break bad habits by blocking repeated keys and suggesting better motions.
local cfg = require("config.plugins").hardtime or {}
return {
	"m4xshen/hardtime.nvim",
	enabled = cfg.enabled ~= false,
	branch = cfg.branch,
	event = "VeryLazy",
	dependencies = { "MunifTanjim/nui.nvim" },
	opts = {
		enabled = true, -- Toggle with <leader><leader>t
		max_time = 1000,
		max_count = 3,
		disable_mouse = false,
		hint = true,
		notification = true,
		restricted_keys = {
			["h"] = false,
			["j"] = false,
			["k"] = false,
			["l"] = false,
		},
	},
}
