-- nvim-spider: Better word motions that recognize camelCase, SNAKE_CASE, and kebab-case.
-- Replaces default w, e, b motions with subword-aware versions.
local cfg = require("config.plugins").spider or {}
return {
	"chrisgrieser/nvim-spider",
	enabled = cfg.enabled ~= false,
	branch = cfg.branch,
	keys = {
		{ "w", "<cmd>lua require('spider').motion('w')<cr>", mode = { "n", "o", "x" }, desc = "Spider w" },
		{ "e", "<cmd>lua require('spider').motion('e')<cr>", mode = { "n", "o", "x" }, desc = "Spider e" },
		{ "b", "<cmd>lua require('spider').motion('b')<cr>", mode = { "n", "o", "x" }, desc = "Spider b" },
	},
	opts = {
		skipInsignificantPunctuation = true,
		subwordMovement = true,
		consistentOperatorPending = false,
	},
}
