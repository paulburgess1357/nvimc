-- copilot.vim: GitHub Copilot integration for Neovim.
-- Provides AI-powered code suggestions and completions.
local cfg = require("config.plugins").copilot or {}
return {
	"github/copilot.vim",
	enabled = cfg.enabled ~= false,
	branch = cfg.branch,
	cmd = "Copilot",
	event = "InsertEnter",
	config = function()
		vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = "#444444", italic = true })
	end,
}
