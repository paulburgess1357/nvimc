-- copilot.vim: GitHub Copilot integration for Neovim.
-- Provides authentication for CodeCompanion and inline suggestions.
local cfg = require("config.plugins").copilot or {}
return {
	"github/copilot.vim",
	enabled = cfg.enabled ~= false,
	branch = cfg.branch,
	event = "VeryLazy",
	config = function()
		if cfg.inline_suggestions then
			vim.g.copilot_no_tab_map = true
			vim.keymap.set("i", "<Tab>", 'copilot#Accept("<CR>")', { expr = true, replace_keycodes = false })
		else
			vim.g.copilot_filetypes = { ["*"] = false }
		end
		vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = "#555555", italic = true })
	end,
}
