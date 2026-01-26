-- CodeCompanion.nvim: AI-powered coding assistant
-- https://github.com/olimorris/codecompanion.nvim

local cfg = require("config.plugins").codecompanion or {}

-- ============================================================================
-- Settings
-- ============================================================================
-- This section configures the AI provider and model used by CodeCompanion.
-- Change DEFAULT_ADAPTER to switch between providers (anthropic, copilot, etc.)
-- Change DEFAULT_MODEL to override the provider's default model (or leave nil)

-- Provider: "anthropic", "copilot", "openai", "gemini", "ollama"
local DEFAULT_ADAPTER = "anthropic"

-- Model: nil uses adapter's default
-- Anthropic: "claude-sonnet-4-5", "claude-opus-4-5", "claude-haiku-4-5"
-- Copilot:   "claude-sonnet-4.5", "claude-opus-4.5", "gpt-4.1", "gpt-4o"
-- OpenAI:    "gpt-4o", "gpt-4o-mini", "o1", "o3-mini"
-- Gemini:    "gemini-2.0-flash", "gemini-1.5-pro", "gemini-1.5-flash"
-- Ollama:    "llama3.2", "llama3.1", "codellama", "mistral"
local DEFAULT_MODEL = nil

-- ============================================================================
-- Helpers
-- ============================================================================

-- Returns the adapter configuration for CodeCompanion
-- If a custom model is specified, returns a table with adapter name and model
-- Otherwise, returns just the adapter name to use its default model
local function get_adapter()
	if DEFAULT_MODEL then
		return { name = DEFAULT_ADAPTER, model = DEFAULT_MODEL }
	end
	return DEFAULT_ADAPTER
end

-- Loads and concatenates all markdown files from the startup prompts directory
-- Files are sorted alphabetically and joined with double newlines
-- Returns a single string containing the combined system prompt
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

local NEOVIM_HINT =
	"Use @{neovim} for file operations (read, write, edit, move, delete), directory listing, file search, Lua execution, and shell commands."

-- Sends the current visual selection to the AI chat
-- include_content: if true, sends the actual code; if false, sends only file/line reference
-- Opens or reuses the last chat and focuses the chat window
local function send_to_chat(include_content)
	local start_line = vim.fn.line("'<")
	local end_line = vim.fn.line("'>")
	local filename = vim.fn.expand("%:.")

	local header = string.format(
		"The lines %d-%d for file `%s` refer to #{buffer}. %s\n\n",
		start_line,
		end_line,
		filename,
		NEOVIM_HINT
	)

	local content = header
	if include_content then
		local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
		local filetype = vim.bo.filetype
		content = header .. string.format("\n```%s\n%s\n```\n", filetype, table.concat(lines, "\n"))
	end

	local cc = require("codecompanion")
	local chat = cc.last_chat() or cc.chat()
	if chat then
		chat:add_buf_message({ role = "user", content = content })
		chat.ui:open()
		vim.schedule(function()
			if chat.bufnr and vim.api.nvim_buf_is_valid(chat.bufnr) then
				local win = vim.fn.bufwinid(chat.bufnr)
				if win ~= -1 then
					vim.api.nvim_set_current_win(win)
				end
			end
		end)
	end
end

-- Opens the CodeCompanion log file in the current window
local function open_log()
	vim.cmd("edit " .. vim.fn.stdpath("log") .. "/codecompanion.log")
end

-- Creates a new chat session and initializes it with the Neovim hint
-- The hint reminds the AI about available @{neovim} tool capabilities
local function new_chat_with_init()
	local cc = require("codecompanion")
	local chat = cc.chat()
	if chat then
		vim.schedule(function()
			chat:add_buf_message({ role = "user", content = NEOVIM_HINT .. "\n\n" })
		end)
	end
end

-- Toggles the most recent chat window if one exists
-- Otherwise, creates a new chat with initialization hint
local function toggle_chat()
	local cc = require("codecompanion")
	if cc.last_chat() then
		vim.cmd("CodeCompanionChat Toggle")
	else
		new_chat_with_init()
	end
end

-- ============================================================================
-- Commands
-- ============================================================================

local function setup_commands()
	local cmd = vim.api.nvim_create_user_command

	-- Chat
	cmd("Chat", toggle_chat, { desc = "Toggle AI chat" })
	cmd("ChatNew", new_chat_with_init, { desc = "New AI chat" })
	cmd("NewChat", new_chat_with_init, { desc = "New AI chat" })
	cmd("ChatHistory", "CodeCompanionHistory", { desc = "Browse chat history" })

	-- Send selection with file/line context
	cmd("ChatSend", function()
		send_to_chat(true)
	end, { range = true, desc = "Send selection to chat" })
	cmd("SendChat", function()
		send_to_chat(true)
	end, { range = true, desc = "Send selection to chat" })

	-- Send reference (file/line only, no content)
	cmd("SendRef", function()
		send_to_chat(false)
	end, { range = true, desc = "Send file/line reference to chat" })
	cmd("RefSend", function()
		send_to_chat(false)
	end, { range = true, desc = "Send file/line reference to chat" })

	-- Log
	cmd("ChatLog", open_log, { desc = "Open CodeCompanion log" })
	cmd("LogChat", open_log, { desc = "Open CodeCompanion log" })
end

local function setup_chat_keymaps()
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "codecompanion",
		callback = function(ev)
			-- Disable buffer-switching keys that conflict with chat
			for _, key in ipairs({ "<S-h>", "<S-l>", "<leader>-", "<leader>|" }) do
				vim.keymap.set("n", key, "<nop>", { buffer = ev.buf })
			end
		end,
	})
end

-- ============================================================================
-- Plugin
-- ============================================================================

return {
	"olimorris/codecompanion.nvim",
	enabled = cfg.enabled ~= false,
	branch = cfg.branch,

	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"github/copilot.vim",
		"ravitemer/codecompanion-history.nvim",
	},

	cmd = {
		"CodeCompanion",
		"CodeCompanionChat",
		"CodeCompanionActions",
		"CodeCompanionHistory",
		-- Aliases
		"Chat",
		"ChatNew",
		"NewChat",
		"ChatHistory",
		"ChatSend",
		"SendChat",
		"SendRef",
		"RefSend",
		"ChatLog",
		"LogChat",
	},

	config = function(_, opts)
		require("codecompanion").setup(opts)
		setup_commands()
		setup_chat_keymaps()
	end,

	opts = {
		opts = {
			log_level = "WARN",
		},

		interactions = {
			chat = {
				adapter = get_adapter(),
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
					system_prompt = load_system_prompt,
				},
			},
			inline = { adapter = get_adapter() },
			cmd = { adapter = get_adapter() },
		},

		display = {
			action_palette = { provider = "fzf_lua" },
			chat = {
				show_settings = false,
				show_token_count = true,
				show_reasoning = true,
				fold_reasoning = true,
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
			history = {
				enabled = true,
				opts = {
					keymap = "gh",
					auto_save = true,
					auto_generate_title = true,
					continue_last_chat = false,
					picker = "snacks", -- fzf_lua doesn't support delete/rename keymaps well
					dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
					chat_filter = function(chat)
						return chat.cwd == vim.fn.getcwd()
					end,
				},
			},
		},
	},
}
