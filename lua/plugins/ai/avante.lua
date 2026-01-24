-- Avante.nvim: AI-powered coding assistant (Cursor-like experience)
-- https://github.com/yetone/avante.nvim
--
-- This plugin provides AI-driven code suggestions with one-click apply.
-- Supports multiple providers: Anthropic Claude, GitHub Copilot, OpenAI, etc.
--
-- Commands: :Chat, :ChatNew, :ChatAsk, :ChatEdit, :ChatFocus,
--           :ChatHistory, :ChatModels, :ChatProvider, :ChatStop, :ChatClear

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

		-- Chat aliases
		"Chat",
		"ChatNew",
		"ChatAsk",
		"ChatEdit",
		"ChatFocus",
		"ChatHistory",
		"ChatModels",
		"ChatProvider",
		"ChatStop",
		"ChatClear",
		"ChatReset",
	},

	config = function(_, opts)
		require("avante").setup(opts)

		-- Make sidebar separator match theme's window separator
		vim.api.nvim_set_hl(0, "AvanteSidebarWinSeparator", { link = "WinSeparator" })

		-- Chat command aliases
		vim.api.nvim_create_user_command("Chat", "AvanteToggle", { desc = "Toggle AI chat" })
		vim.api.nvim_create_user_command("ChatNew", "AvanteChatNew", { desc = "New AI chat" })
		vim.api.nvim_create_user_command("ChatAsk", "AvanteAsk", { desc = "Ask AI" })
		vim.api.nvim_create_user_command("ChatEdit", "AvanteEdit", { desc = "AI edit selection" })
		vim.api.nvim_create_user_command("ChatFocus", "AvanteFocus", { desc = "Focus AI chat" })
		vim.api.nvim_create_user_command("ChatHistory", "AvanteHistory", { desc = "AI chat history" })
		vim.api.nvim_create_user_command("ChatModels", "AvanteModels", { desc = "Switch AI model" })
		vim.api.nvim_create_user_command("ChatProvider", function(o)
			if o.args == "" then
				local p = require("avante.config").provider
				vim.notify("Provider: " .. p, vim.log.levels.INFO)
			else
				vim.cmd("AvanteSwitchProvider " .. o.args)
			end
		end, { nargs = "?", desc = "Show/switch AI provider" })
		vim.api.nvim_create_user_command("ChatStop", "AvanteStop", { desc = "Stop AI generation" })
		vim.api.nvim_create_user_command("ChatClear", "AvanteClear", { desc = "Clear AI chat" })
		vim.api.nvim_create_user_command("ChatReset", function()
			local config_file = vim.fn.expand("~/.config/avante.nvim/config.json")
			if vim.fn.filereadable(config_file) == 1 then
				vim.fn.delete(config_file)
				vim.notify("Avante model selection cleared. Restart Neovim.", vim.log.levels.INFO)
			else
				vim.notify("No saved model selection found.", vim.log.levels.WARN)
			end
		end, { desc = "Reset Avante model selection (requires restart)" })
	end,

	opts = {
		-- Provider: "claude", "copilot", "openai", "gemini", "ollama", etc.
		provider = DEFAULT_PROVIDER,

		-- Mode: "agentic" (newer, more capable) or "legacy"
		mode = "agentic",

		-- Provider configurations
		-- Models by provider (use :ChatModels to list available):
		--   claude:  claude-sonnet-4-20250514, claude-opus-4-20250514
		--   copilot: gpt-4o-2024-11-20, gpt-4.1, o4-mini (fetched dynamically)
		--   openai:  gpt-4o, gpt-4o-mini, o1, o3-mini
		--   gemini:  gemini-2.0-flash, gemini-1.5-pro
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
				model = "gpt-4o-2024-11-20", -- use :ChatModels to see available
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
			border = "none", -- "single", "double", "rounded", "solid", "shadow", or "none"
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

		-- Use fzf for all selection UIs
		selector = { provider = "fzf_lua" },
		file_selector = { provider = "fzf_lua" },

		-- Hints (virtual text)
		hints = {
			enabled = true,
		},
	},
}
