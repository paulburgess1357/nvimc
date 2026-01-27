-- Centralized plugin configuration
-- Enable/disable plugins and specify branches from one place
--
-- Each entry: key = { enabled = bool, branch = "string" (optional) }
-- If enabled is omitted, defaults to true
-- If branch is omitted, uses plugin default

return {
	-- Global settings
	settings = {
		treesitter_max_kb = 100, -- Disable treesitter for files larger than this (KB)
		illuminate_max_lines = 20000, -- nil = no limit
		bigfile_max_mb = 1.5, -- Snacks bigfile threshold (MB)
		aerial_max_lines = 50000, -- Disable aerial for files with more lines
	},

	-- Coding
	treesitter = { enabled = true, branch = "main" },
	lsp = { enabled = true },
	mason = { enabled = true },
	blink = { enabled = true },
	conform = { enabled = true },
	lint = { enabled = true },
	increname = { enabled = true },
	pairs = { enabled = true },

	-- Editor
	minifiles = { enabled = true },
	fzf = { enabled = true },
	gitsigns = { enabled = true },
	spider = { enabled = true },
	illuminate = { enabled = true },
	todocomments = { enabled = true },
	rendermarkdown = { enabled = true },
	hardtime = { enabled = true },

	-- UI
	colorscheme = { enabled = true },
	lualine = { enabled = true },
	whichkey = { enabled = true },
	snacks = { enabled = true },
	noice = { enabled = true },
	rainbowdelimiters = { enabled = true },
	scrollview = { enabled = false },
	aerial = { enabled = true },
	marks = { enabled = true },

	-- Debug
	dap = { enabled = true },

	-- AI (adapter/model configured in lua/plugins/ai/codecompanion.lua)
	-- copilot: GitHub Copilot integration with inline suggestion support
	-- codecompanion: Chat-based AI assistant for code generation and refactoring
	-- mcphub: MCP (Model Context Protocol) hub for AI tool integration
	copilot = { enabled = true, inline_suggestions = false },
	codecompanion = { enabled = true, branch = "main" },
	mcphub = { enabled = true },

	-- Personal (auto-disabled on push via .git/hooks/pre-push)
	leetneo = { enabled = true, branch = "master" },
}
