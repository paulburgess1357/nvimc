-- CodeCompanion: AI coding assistant with chat and inline editing.
-- Supports Claude, GPT, Copilot, Ollama, and many other providers.
local plugins = require("config.plugins")
local cfg = plugins.codecompanion or {}

return {
	"olimorris/codecompanion.nvim",
	enabled = cfg.enabled ~= false,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	opts = {
		strategies = {
			chat = {
				adapter = "anthropic",
			},
			inline = {
				adapter = "anthropic",
			},
		},
		adapters = {
			anthropic = function()
				return require("codecompanion.adapters").extend("anthropic", {
					env = {
						api_key = "ANTHROPIC_API_KEY",
					},
				})
			end,
		},
		display = {
			chat = {
				window = {
					layout = "vertical",
					width = 0.4,
				},
			},
		},
	},
	keys = {
		{ "<leader>aa", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "AI Actions" },
		{ "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "AI Chat" },
		{ "<leader>ai", "<cmd>CodeCompanion<cr>", mode = { "n", "v" }, desc = "AI Inline" },
		{ "<leader>ap", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "AI Add to Chat" },
	},
}
