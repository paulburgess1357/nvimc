-- copilot.lua: GitHub Copilot integration for Neovim
-- https://github.com/zbirenbaum/copilot.lua
--
-- Provides inline suggestions and authentication for Avante copilot provider.
-- Using copilot.lua (Lua rewrite) instead of copilot.vim for better integration.

local cfg = require("config.plugins").copilot or {}

return {
	"zbirenbaum/copilot.lua",
	enabled = cfg.enabled ~= false,
	cmd = "Copilot",
	event = "InsertEnter",
	config = function()
		require("copilot").setup({
			panel = {
				enabled = false, -- Using Avante instead
			},
			suggestion = {
				enabled = cfg.inline_suggestions ~= false,
				auto_trigger = true,
				keymap = {
					accept = "<Tab>",
					accept_word = "<M-w>",
					accept_line = "<M-l>",
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<C-]>",
				},
			},
			filetypes = {
				yaml = true,
				markdown = true,
				help = false,
				gitcommit = false,
				gitrebase = false,
				["."] = false,
			},
		})

		-- Match the original highlight style
		vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = "#555555", italic = true })
	end,
}
