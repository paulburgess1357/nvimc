-- LeetNeoCode: LeetCode problem solving in Neovim.
-- Fetch, solve, and manage LeetCode problems with multi-language support.
local cfg = require("config.plugins").leetneo or {}
return {
	"paulburgess1357/LeetNeoCode",
	enabled = cfg.enabled ~= false,
	branch = cfg.branch,
	dir = "/home/paul/Repos/LeetNeoCode",
	cmd = { "LC", "LCPull", "LCCopy", "LCRecent", "LCKeywords", "LCFold" },
	opts = {
		cache_dir = "/home/paul/.cache/nvim/LeetNeoCode",
		default_language = "cpp",
		code_only = true,
		enable_images = false,
		smart_copy = true,
		cache_expiry_days = 13,
	},
}
