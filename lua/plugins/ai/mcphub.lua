-- mcphub.nvim: MCP (Model Context Protocol) client for Neovim.
--
-- This plugin enables Neovim to communicate with MCP servers, which provide
-- various tools and capabilities (file system access, database queries, API calls, etc.)
-- that can be used by AI assistants through CodeCompanion.
--
-- MCP is a standardized protocol for connecting AI models to different data sources
-- and tools, allowing LLMs to interact with external systems in a secure and controlled way.
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
