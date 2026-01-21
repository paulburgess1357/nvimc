-- CodeCompanion.nvim: AI-powered coding assistant
-- https://github.com/olimorris/codecompanion.nvim

local cfg = require("config.plugins").codecompanion or {}

-- ============================================================================
-- Configuration
-- ============================================================================

-- Change DEFAULT_ADAPTER to switch providers
local DEFAULT_ADAPTER = "anthropic"

-- Models per adapter (change these to use different models)
--
-- Anthropic (direct API, requires ANTHROPIC_API_KEY):
--   claude-sonnet-4-5-20250929  ($3/$15)   Best for coding, Jan 2025 knowledge
--   claude-haiku-4-5-20251001   ($1/$5)    Fast, cheap
--   claude-opus-4-5-20251101    ($5/$25)   Most intelligent, May 2025 knowledge
--   claude-sonnet-4-20250514    ($3/$15)   Previous gen
--
-- Copilot (via GitHub subscription):
--   claude-sonnet-4, claude-sonnet-4.5, gpt-4o, gpt-4.1, o1, o3-mini
--
-- OpenAI (requires OPENAI_API_KEY):
--   gpt-4o, gpt-4o-mini, gpt-4-turbo, o1, o1-mini, o3-mini
--
-- Gemini (requires GEMINI_API_KEY):
--   gemini-2.0-flash, gemini-1.5-pro, gemini-1.5-flash
--
-- Ollama (local, free):
--   llama3.2, llama3.1, codellama, mistral, deepseek-coder
--
local MODELS = {
	anthropic = "claude-sonnet-4-5-20250929",
	copilot = "claude-sonnet-4.5",
	openai = "gpt-4o",
	gemini = "gemini-2.0-flash",
	ollama = "llama3.2",
}

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
		-- Adapters: customize model defaults
		adapters = {
			anthropic = function()
				return require("codecompanion.adapters").extend("anthropic", {
					schema = { model = { default = MODELS.anthropic } },
				})
			end,
			copilot = function()
				return require("codecompanion.adapters").extend("copilot", {
					schema = { model = { default = MODELS.copilot } },
				})
			end,
			openai = function()
				return require("codecompanion.adapters").extend("openai", {
					schema = { model = { default = MODELS.openai } },
				})
			end,
			gemini = function()
				return require("codecompanion.adapters").extend("gemini", {
					schema = { model = { default = MODELS.gemini } },
				})
			end,
			ollama = function()
				return require("codecompanion.adapters").extend("ollama", {
					schema = { model = { default = MODELS.ollama } },
				})
			end,
		},

		-- Interactions
		interactions = {
			chat = {
				adapter = DEFAULT_ADAPTER,
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
				adapter = DEFAULT_ADAPTER,
			},
			cmd = {
				adapter = DEFAULT_ADAPTER,
			},
		},

		-- Display
		display = {
			chat = {
				show_settings = true,
				show_reasoning = true,
				fold_reasoning = false,
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
