-- store.nvim: Plugin discovery browser with 5500+ plugins database.
-- Browse, search, and install plugins with live README preview.
local cfg = require("config.plugins").store or {}
return {
	"alex-popov-tech/store.nvim",
	enabled = cfg.enabled ~= false,
	branch = cfg.branch,
	dependencies = { "OXY2DEV/markview.nvim" },
	cmd = "Store",
	opts = {},
}
