local plugins = require("config.plugins")
local cfg = plugins.rainbowdelimiters or {}
local settings = plugins.settings or {}
if cfg.enabled == false then return end

require("rainbow-delimiters.setup").setup({
	-- Not above settings.treesitter_max_kb, the limit treesitter itself
	-- stops at (plugin/coding/treesitter.lua): the global strategy colors the
	-- whole buffer when it attaches, and parses it to do so, which froze
	-- the editor for seconds on a file of 60k lines.
	condition = function(bufnr)
		local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
		return not (ok and stats and stats.size > (settings.treesitter_max_kb or 100) * 1024)
	end,
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
