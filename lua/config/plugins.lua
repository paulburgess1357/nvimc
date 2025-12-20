-- Centralized plugin configuration
-- Enable/disable plugins and specify branches from one place
--
-- Each entry: key = { enabled = bool, branch = "string" (optional) }
-- If enabled is omitted, defaults to true
-- If branch is omitted, uses plugin default

return {
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

	-- UI
	colorscheme = { enabled = true },
	lualine = { enabled = true },
	whichkey = { enabled = true },
	snacks = { enabled = true },
	noice = { enabled = true },
	incline = { enabled = true },
	navic = { enabled = true },
	rainbowdelimiters = { enabled = true },
	scrollview = { enabled = true },
	aerial = { enabled = true },

	-- Personal (auto-disabled on push via .git/hooks/pre-push)
	leetneo = { enabled = false, branch = "master" },
	store = { enabled = false },
}
