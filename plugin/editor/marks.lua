local cfg = require("config.plugins").marks or {}
if cfg.enabled == false then return end

require("marks").setup({
	excluded_filetypes = {
		"minifiles",
		"mason",
		"help",
		"snacks_dashboard",
	},
})
