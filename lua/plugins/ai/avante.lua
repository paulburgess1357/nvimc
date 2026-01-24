-- Avante.nvim: AI-powered coding assistant (Cursor-like experience)
-- https://github.com/yetone/avante.nvim
--
-- This plugin provides AI-driven code suggestions with one-click apply.
-- Supports multiple providers: Anthropic Claude, GitHub Copilot, OpenAI, etc.
--
-- Custom commands: :Chat (toggle), :NewChat (new chat)
-- Provider switch: :AvanteProvider or <leader>ap

local cfg = require("config.plugins").avante or {}

-- ============================================================================
-- Configuration
-- ============================================================================

-- Change this to switch providers: "claude", "copilot", "openai", "gemini", "ollama"
local DEFAULT_PROVIDER = "claude"

-- ============================================================================
-- Plugin Specification
-- ============================================================================

return {
	"yetone/avante.nvim",
	enabled = cfg.enabled ~= false,
	event = "VeryLazy",
	version = false,
	build = "make",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"MeanderingProgrammer/render-markdown.nvim",
		"zbirenbaum/copilot.lua", -- For copilot provider support
	},
	cmd = {
		"AvanteAsk",
		"AvanteChat",
		"AvanteChatNew",
		"AvanteToggle",
		"AvanteEdit",
		"AvanteFocus",
		"AvanteHistory",
		"AvanteModels",
		"AvanteSwitchProvider",
		"AvanteStop",
		"AvanteClear",
		"Chat",
		"NewChat",
		"ChatNew",
	},

	config = function(_, opts)
		require("avante").setup(opts)

		-- Custom commands to match CodeCompanion style
		vim.api.nvim_create_user_command("Chat", "AvanteToggle", { desc = "Toggle AI chat" })
		vim.api.nvim_create_user_command("NewChat", "AvanteChatNew", { desc = "New AI chat" })
		vim.api.nvim_create_user_command("ChatNew", "AvanteChatNew", { desc = "New AI chat" })
		vim.api.nvim_create_user_command("AvanteProvider", "AvanteSwitchProvider", { desc = "Switch AI provider" })
	end,

	opts = {
		-- Provider: "claude", "copilot", "openai", "gemini", "ollama", etc.
		provider = DEFAULT_PROVIDER,

		-- Mode: "agentic" (newer, more capable) or "legacy"
		mode = "agentic",

		-- Provider configurations
		providers = {
			claude = {
				endpoint = "https://api.anthropic.com",
				model = "claude-sonnet-4-20250514",
				timeout = 30000,
				extra_request_body = {
					temperature = 0.7,
					max_tokens = 16384,
				},
			},
			copilot = {
				endpoint = "https://api.githubcopilot.com",
				model = "claude-sonnet-4",
				timeout = 30000,
				extra_request_body = {
					temperature = 0.7,
					max_tokens = 16384,
				},
			},
		},

		-- Keymaps (set to false to disable and define your own)
		mappings = {
			ask = "<leader>aa",
			edit = "<leader>ae",
			refresh = "<leader>ar",
			focus = "<leader>af",
			toggle = {
				default = "<leader>at",
				debug = "<leader>ad",
				hint = "<leader>ah",
				suggestion = "<leader>as",
			},
			diff = {
				next = "]x",
				prev = "[x",
			},
		},

		-- Behavior settings
		behaviour = {
			auto_focus_sidebar = true,
			auto_suggestions = false,
			auto_set_keymaps = true,
			auto_set_highlight_group = true,
			auto_apply_diff_after_generation = false,
			minimize_diff = true,
			enable_token_counting = true,
		},

		-- Window configuration
		windows = {
			position = "right",
			width = 40, -- percentage
			wrap = true,
			sidebar_header = {
				enabled = true,
				align = "center",
				rounded = true,
			},
			input = {
				height = 8,
			},
			ask = {
				floating = false,
				start_insert = true,
			},
		},

		-- Hints (virtual text)
		hints = {
			enabled = true,
		},
	},
}
