-- CodeCompanion.nvim: AI-powered coding assistant.
-- Chat, inline assistance, and agent workflows.
local cfg = require("config.plugins").codecompanion or {}

-- Default adapter and model (change these to switch providers)
-- Adapters: anthropic, copilot, openai, gemini, ollama
--
-- Anthropic API models (Jan 2025):
--   claude-opus-4-5-20251101    $5/$25   Premium, max intelligence
--   claude-sonnet-4-5-20250929  $3/$15   Best balance, coding/agents (recommended)
--   claude-haiku-4-5-20251001   $1/$5    Fastest, low latency
--   claude-sonnet-4-20250514    $3/$15   Legacy
--   claude-opus-4-1-20250805    $15/$75  Legacy
--
-- Copilot models (simpler names):
--   claude-opus-4.5, claude-sonnet-4, claude-haiku-4.5, gpt-4o
--
local default_adapter = "anthropic"
local default_model = "claude-sonnet-4-5-20250929"
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
					name = default_adapter,
					model = default_model,
				},
			},
			inline = {
				adapter = {
					name = default_adapter,
					model = default_model,
				},
			},
			agent = {
				adapter = {
					name = default_adapter,
					model = default_model,
				},
			},
		},
		display = {
			chat = {
				show_settings = false,
				window = {
					layout = "vertical",
					width = 0.4,
				},
			},
		},
		extensions = {
			mcphub = {
				callback = "mcphub.extensions.codecompanion",
				opts = {
					make_tools = true,
					show_server_tools_in_chat = true,
					make_vars = true,
					make_slash_commands = true,
				},
			},
		},
	},
}
