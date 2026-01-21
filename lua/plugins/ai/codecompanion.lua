-- CodeCompanion.nvim: AI-powered coding assistant
-- https://github.com/olimorris/codecompanion.nvim
--
-- This plugin provides an AI-powered coding assistant with chat, inline completions,
-- and code actions. It supports multiple AI providers (Anthropic, Copilot, OpenAI,
-- Gemini, Ollama) and can be configured to use different models for different tasks.
--
-- Custom commands: :Chat (toggle), :NewChat/:ChatNew (new chat)
-- System prompts are loaded from lua/plugins/ai/prompts/startup/*.md

local cfg = require("config.plugins").codecompanion or {}

-- ============================================================================
-- Configuration
-- ============================================================================

-- Change this to switch providers: "copilot", "anthropic", "openai", "gemini", "ollama"
local DEFAULT_ADAPTER = "anthropic"

-- Default model (set to nil to use adapter's default, or specify a model)
-- Anthropic: "claude-sonnet-4-5-20250514", "claude-opus-4-5-20251101", "claude-haiku-4-5-20251001"
-- Copilot:   "claude-sonnet-4", "claude-sonnet-4.5", "gpt-4o", "gpt-4.1", "o1", "o3-mini"
-- OpenAI:    "gpt-4o", "gpt-4o-mini", "gpt-4-turbo", "o1", "o1-mini", "o3-mini"
-- Gemini:    "gemini-2.0-flash", "gemini-1.5-pro", "gemini-1.5-flash"
-- Ollama:    "llama3.2", "llama3.1", "codellama", "mistral", "deepseek-coder"
local DEFAULT_MODEL = nil

-- Show model/settings info at top of chat buffer
local SHOW_CHAT_SETTINGS = false

-- ============================================================================
-- Helper Functions
-- ============================================================================

-- Load system prompt from markdown files in prompts/startup/
local function load_system_prompt()
	local startup_dir = vim.fn.stdpath("config") .. "/lua/plugins/ai/prompts/startup"
	local files = vim.fn.glob(startup_dir .. "/*.md", false, true)
	table.sort(files)

	local parts = {}
	for _, file in ipairs(files) do
		local f = io.open(file, "r")
		if f then
			table.insert(parts, f:read("*a"))
			f:close()
		end
	end

	return table.concat(parts, "\n\n")
end

-- ============================================================================
-- Plugin Specification
-- ============================================================================

return {
	"olimorris/codecompanion.nvim",
	enabled = cfg.enabled ~= false,
	branch = cfg.branch,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"github/copilot.vim",
	},
	cmd = {
		"CodeCompanion",
		"CodeCompanionChat",
		"CodeCompanionActions",
		"Chat",
		"NewChat",
		"ChatNew",
	},

	config = function(_, opts)
		require("codecompanion").setup(opts)

		-- Custom commands
		vim.api.nvim_create_user_command("Chat", "CodeCompanionChat Toggle", { desc = "Toggle AI chat" })
		vim.api.nvim_create_user_command("NewChat", "CodeCompanionChat", { desc = "New AI chat" })
		vim.api.nvim_create_user_command("ChatNew", "CodeCompanionChat", { desc = "New AI chat" })

		-- Disable buffer-switching keys in chat buffers
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "codecompanion",
			callback = function(ev)
				local disabled_keys = { "<S-h>", "<S-l>", "<leader>-", "<leader>|" }
				for _, key in ipairs(disabled_keys) do
					vim.keymap.set("n", key, "<nop>", { buffer = ev.buf })
				end
			end,
		})
	end,

	opts = {
		-- Interactions: set which adapter to use for each interaction type
		-- Change these to your preferred adapter: "copilot", "anthropic", "openai", "gemini", "ollama"
		interactions = {
			chat = {
				adapter = DEFAULT_MODEL and { name = DEFAULT_ADAPTER, model = DEFAULT_MODEL } or DEFAULT_ADAPTER,
				roles = { user = "Me" },
				keymaps = {
					close = {
						modes = { n = "q" },
						callback = function()
							vim.cmd("CodeCompanionChat Toggle")
						end,
					},
				},
				opts = {
					system_prompt = function(ctx)
						return load_system_prompt()
					end,
				},
			},
			inline = {
				adapter = DEFAULT_MODEL and { name = DEFAULT_ADAPTER, model = DEFAULT_MODEL } or DEFAULT_ADAPTER,
			},
			cmd = {
				adapter = DEFAULT_MODEL and { name = DEFAULT_ADAPTER, model = DEFAULT_MODEL } or DEFAULT_ADAPTER,
			},
		},

		-- Display settings
		display = {
			chat = {
				show_settings = SHOW_CHAT_SETTINGS,
				show_token_count = true,
				-- Reasoning/thinking display
				show_reasoning = true,
				fold_reasoning = true, -- Folds after streaming completes
				window = {
					layout = "vertical",
					width = 0.4,
				},
			},
		},

		-- Extensions
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
