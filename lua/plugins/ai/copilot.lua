-- copilot.vim: GitHub Copilot integration for Neovim.
-- Provides authentication for CodeCompanion and inline suggestions.
local cfg = require("config.plugins").copilot or {}
return {
	"github/copilot.vim",
	enabled = cfg.enabled ~= false,
	branch = cfg.branch,
	event = "VeryLazy",
	config = function()
		vim.g.copilot_no_tab_map = true -- Don't use tab for accepting suggestions
		vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = "#555555", italic = true })
	end,
}
