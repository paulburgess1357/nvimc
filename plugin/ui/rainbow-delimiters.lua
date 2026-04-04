local cfg = require("config.plugins").rainbowdelimiters or {}
if cfg.enabled == false then return end

require("rainbow-delimiters.setup").setup({
	strategy = {
		[""] = "rainbow-delimiters.strategy.global",
		vim = "rainbow-delimiters.strategy.local",
	},
	query = {
		[""] = "rainbow-delimiters",
		lua = "rainbow-blocks",
	},
	priority = {
		[""] = 110,
		lua = 210,
	},
	highlight = {
		"RainbowDelimiterRed",
		"RainbowDelimiterYellow",
		"RainbowDelimiterBlue",
		"RainbowDelimiterOrange",
		"RainbowDelimiterGreen",
		"RainbowDelimiterViolet",
		"RainbowDelimiterCyan",
	},
})
