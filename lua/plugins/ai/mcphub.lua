-- mcphub.nvim: MCP (Model Context Protocol) client for Neovim.
-- Integrates MCP servers with CodeCompanion for extended tool access.
local cfg = require("config.plugins").mcphub or {}
return {
	"ravitemer/mcphub.nvim",
	enabled = cfg.enabled ~= false,
	branch = cfg.branch,
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	build = "bundled_build.lua",
	cmd = { "MCPHub" },
	config = function()
		require("mcphub").setup({
			use_bundled_binary = true,
		})
	end,
}
