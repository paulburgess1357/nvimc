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
		cppcheck = false, -- Enable cppcheck for C/C++ linting (requires nvim-lint)
	},

	-- Coding
	treesitter = { enabled = true, branch = "main" }, -- Syntax highlighting and code parsing
	lsp = { enabled = true }, -- Language server protocol support
	mason = { enabled = true }, -- LSP/DAP/linter/formatter installer
	blink = { enabled = true }, -- Autocompletion engine
	conform = { enabled = true }, -- Code formatting
	lint = { enabled = true }, -- Async linting
	increname = { enabled = true }, -- Live-preview LSP rename
	pairs = { enabled = true }, -- Auto-close brackets, quotes, etc.

	-- Editor
	minifiles = { enabled = true }, -- File explorer
	fzf = { enabled = true }, -- Fuzzy finder
	gitsigns = { enabled = true }, -- Git diff signs in the gutter
	diffview = { enabled = true }, -- Side-by-side diff viewer
	spider = { enabled = true }, -- Smarter word motions (camelCase-aware)
	illuminate = { enabled = true }, -- Highlight other uses of word under cursor
	todocomments = { enabled = true }, -- Highlight and search TODO/FIXME/etc.
	rendermarkdown = { enabled = true }, -- In-buffer markdown rendering

	-- UI
	colorscheme = { enabled = true, theme = "onedark" }, -- Color theme
	lualine = { enabled = true }, -- Statusline
	whichkey = { enabled = true }, -- Keybinding hints popup
	snacks = { enabled = true }, -- UI utilities (bigfile, dashboard, etc.)
	noice = { enabled = true }, -- Cmdline, messages, and popupmenu UI
	rainbowdelimiters = { enabled = true }, -- Colored matching brackets
	aerial = { enabled = true }, -- Code outline / symbol sidebar
	marks = { enabled = true }, -- Visual marks in the gutter

	-- Debug
	dap = { enabled = true }, -- Debug adapter protocol support

	-- Personal (auto-disabled on push via .git/hooks/pre-push)
	leetneo = { enabled = false }, -- LeetCode integration
}
