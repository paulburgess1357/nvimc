-- CodeCompanion.nvim: AI-powered coding assistant
-- Provides chat, inline assistance, and agent workflows

local cfg = require("config.plugins").codecompanion or {}

-- ============================================================================
-- Configuration
-- ============================================================================

local DEFAULT_ADAPTER = "anthropic"
local DEFAULT_MODEL = "claude-sonnet-4-5-20250929"

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
		local commands = {
			{ "Chat", "CodeCompanionChat Toggle", "Toggle AI chat" },
			{ "NewChat", "CodeCompanionChat", "New AI chat" },
			{ "ChatNew", "CodeCompanionChat", "New AI chat" },
		}

		for _, cmd in ipairs(commands) do
			vim.api.nvim_create_user_command(cmd[1], cmd[2], { desc = cmd[3] })
		end

		-- Disable buffer-switching keys in chat buffers
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "codecompanion",
			callback = function(ev)
				local keys = { "<S-h>", "<S-l>", "<leader>-", "<leader>|" }
				for _, key in ipairs(keys) do
					vim.keymap.set("n", key, "<nop>", { buffer = ev.buf })
				end
			end,
		})
	end,

	opts = {
		-- Interactions (chat, inline, cmd)
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

		-- Adapters configuration
		adapters = {
			anthropic = function()
				return require("codecompanion.adapters").extend("anthropic", {
					schema = {
						model = { default = DEFAULT_MODEL },
					},
				})
			end,
		},

		-- Display settings
		display = {
			chat = {
				show_settings = true,
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
