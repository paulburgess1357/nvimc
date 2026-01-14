-- copilot.vim: GitHub Copilot integration for Neovim.
-- Provides authentication for CodeCompanion and inline suggestions.
local cfg = require("config.plugins").copilot or {}
return {
	"github/copilot.vim",
	enabled = cfg.enabled ~= false,
	branch = cfg.branch,
	event = "VeryLazy",
	config = function()
		vim.g.copilot_filetypes = { ["*"] = false } -- Disable suggestions in all filetypes
		vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = "#555555", italic = true })
	end,
}
