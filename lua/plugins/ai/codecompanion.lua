-- CodeCompanion.nvim: AI-powered coding assistant.
-- Chat, inline assistance, and agent workflows powered by Copilot.
local cfg = require("config.plugins").codecompanion or {}
return {
	"olimorris/codecompanion.nvim",
	enabled = cfg.enabled ~= false,
	branch = cfg.branch,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"github/copilot.vim",
	},
	cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions", "Chat", "NewChat", "ChatNew" },
	config = function(_, opts)
		require("codecompanion").setup(opts)
		vim.api.nvim_create_user_command("Chat", "CodeCompanionChat Toggle", { desc = "Toggle AI chat" })
		vim.api.nvim_create_user_command("NewChat", "CodeCompanionChat", { desc = "New AI chat" })
		vim.api.nvim_create_user_command("ChatNew", "CodeCompanionChat", { desc = "New AI chat" })
	end,
	opts = {
		strategies = {
			chat = {
				keymaps = {
					close = {
						modes = { n = "q" },
						callback = function()
							vim.cmd("CodeCompanionChat Toggle")
						end,
					},
				},
				adapter = {
					name = "copilot",
					model = "claude-haiku-4.5",
				},
			},
			inline = {
				adapter = {
					name = "copilot",
					model = "claude-haiku-4.5",
				},
			},
			agent = {
				adapter = {
					name = "copilot",
					model = "claude-haiku-4.5",
				},
			},
		},
		display = {
			chat = {
				show_settings = true,
				window = {
					layout = "vertical",
					width = 0.4,
				},
			},
		},
	},
}
