-- Snacks.nvim: Collection of small QoL plugins (dashboard, indent guides, notifications).
-- Provides a unified configuration for common UI enhancements with minimal overhead.
local plugins = require("config.plugins")
local cfg = plugins.snacks or {}
local settings = plugins.settings or {}

-- Get foreground color from highlight group (with fallback chain)
local function get_hl_fg(...)
	for _, name in ipairs({ ... }) do
		local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
		if hl.fg then
			return string.format("#%06x", hl.fg)
		end
	end
	return nil
end

-- Build gradient colors dynamically from current colorscheme
local function get_gradient_colors()
	return {
		get_hl_fg("@keyword", "Keyword", "Statement") or "#888888",
		get_hl_fg("@function", "Function") or "#888888",
		get_hl_fg("@property", "@field", "Identifier") or "#888888",
		get_hl_fg("@string", "String") or "#888888",
		get_hl_fg("@type", "Type") or "#888888",
		get_hl_fg("@number", "@constant", "Constant", "Number") or "#888888",
	}
end

return {
	"folke/snacks.nvim",
	enabled = cfg.enabled ~= false,
	branch = cfg.branch,
	priority = 1000,
	lazy = false,
	opts = {
		-- Performance optimizations for large files
		bigfile = {
			enabled = true,
			notify = true,
			size = (settings.bigfile_max_mb or 1.5) * 1024 * 1024,
			-- Disable features for big files
			setup = function(ctx)
				vim.cmd([[NoMatchParen]])
				vim.opt_local.swapfile = false
				vim.opt_local.foldmethod = "manual"
				vim.opt_local.undolevels = -1
				vim.opt_local.undoreload = 0
				vim.opt_local.list = false
			end,
		},

		-- Startup dashboard with gradient header
		dashboard = {
			enabled = true,
			preset = {
				keys = {
					{ icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
					{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
					{ icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
					{ icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
					{
						icon = " ",
						key = "c",
						desc = "Config",
						action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
					},
					{ icon = " ", key = "l", desc = "Lazy", action = ":Lazy" },
					{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
				},
			},
			sections = {
				-- Gradient header - each line gets its own color
				{
					text = {
						{
							"███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
							hl = "DashboardGradient1",
						},
					},
					align = "center",
					padding = 0,
				},
				{
					text = {
						{
							"████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
							hl = "DashboardGradient2",
						},
					},
					align = "center",
					padding = 0,
				},
				{
					text = {
						{
							"██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
							hl = "DashboardGradient3",
						},
					},
					align = "center",
					padding = 0,
				},
				{
					text = {
						{
							"██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
							hl = "DashboardGradient4",
						},
					},
					align = "center",
					padding = 0,
				},
				{
					text = {
						{
							"██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
							hl = "DashboardGradient5",
						},
					},
					align = "center",
					padding = 0,
				},
				{
					text = {
						{
							"╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
							hl = "DashboardGradient6",
						},
					},
					align = "center",
					padding = 1,
				},
				{ section = "keys", gap = 1, padding = 1 },
			},
		},

		-- Indent guides with scope highlighting
		indent = {
			enabled = true,
			indent = {
				char = "│",
				only_scope = false,
				only_current = false,
			},
			scope = {
				enabled = true,
				char = "│",
				underline = false,
			},
			animate = {
				enabled = true,
				duration = {
					step = 20,
					total = 300,
				},
			},
		},

		-- Notification system (disabled - using noice)
		notifier = {
			enabled = false,
		},

		-- Smooth scrolling (disabled - can lag on large buffers)
		scroll = {
			enabled = false,
		},

		-- Terminal
		terminal = {
			enabled = true,
			win = {
				style = "terminal",
			},
		},

		-- Toggle with which-key integration
		toggle = {
			enabled = true,
			which_key = true,
			notify = true,
		},
	},
	init = function()
		local function set_gradient_colors()
			local colors = get_gradient_colors()
			for i, color in ipairs(colors) do
				vim.api.nvim_set_hl(0, "DashboardGradient" .. i, { fg = color })
			end
		end

		-- Set on colorscheme change
		vim.api.nvim_create_autocmd("ColorScheme", {
			pattern = "*",
			callback = set_gradient_colors,
		})

		-- Set immediately
		set_gradient_colors()
	end,
	keys = {
		-- Terminal
		{
			"<C-/>",
			function()
				Snacks.terminal(nil, { cwd = vim.fn.getcwd() })
			end,
			desc = "Terminal (cwd)",
		},
		{
			"<C-_>",
			function()
				Snacks.terminal(nil, { cwd = vim.fn.getcwd() })
			end,
			desc = "Terminal (cwd)",
		},
	},
}
