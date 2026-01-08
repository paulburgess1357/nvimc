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
		-- Dashboard gradient colors
		local function set_gradient_colors()
			local colors = get_gradient_colors()
			for i, color in ipairs(colors) do
				vim.api.nvim_set_hl(0, "DashboardGradient" .. i, { fg = color })
			end
		end
		vim.api.nvim_create_autocmd("ColorScheme", {
			pattern = "*",
			callback = set_gradient_colors,
		})
		set_gradient_colors()

		-- Terminal commands: Term1-9 (bottom row), Term10 (right side, full height)
		local term_bufs = {} -- stores buffer handles by terminal number

		-- Find window displaying a buffer, or nil
		local function find_buf_win(buf)
			for _, w in ipairs(vim.api.nvim_list_wins()) do
				if vim.api.nvim_win_get_buf(w) == buf then return w end
			end
		end

		-- Get open Term1-9 windows sorted by number
		local function get_bottom_term_wins()
			local wins = {}
			for num, buf in pairs(term_bufs) do
				if num <= 9 and vim.api.nvim_buf_is_valid(buf) then
					local w = find_buf_win(buf)
					if w then table.insert(wins, { win = w, num = num }) end
				end
			end
			table.sort(wins, function(a, b) return a.num < b.num end)
			return wins
		end

		-- Create window for Term1-9 at bottom, maintaining left-to-right order
		local function open_bottom_term_win(n)
			local wins = get_bottom_term_wins()
			local after, before
			for _, tw in ipairs(wins) do
				if tw.num < n then after = tw.win
				elseif tw.num > n then before = before or tw.win end
			end

			if after then
				vim.api.nvim_set_current_win(after)
				vim.cmd("vertical belowright split")
			elseif before then
				vim.api.nvim_set_current_win(before)
				vim.cmd("vertical aboveleft split")
			else
				vim.cmd("botright split | resize " .. math.floor(vim.o.lines * 0.3))
			end
		end

		-- Create or toggle a terminal
		local function make_term_cmd(n, open_win_fn)
			return function()
				local buf = term_bufs[n]
				if buf and vim.api.nvim_buf_is_valid(buf) then
					local win = find_buf_win(buf)
					if win then
						vim.api.nvim_win_close(win, false)
					else
						open_win_fn(n)
						vim.api.nvim_set_current_buf(buf)
					end
					return
				end
				open_win_fn(n)
				vim.cmd("terminal")
				buf = vim.api.nvim_get_current_buf()
				term_bufs[n] = buf
				vim.bo[buf].buflisted = false
				vim.api.nvim_buf_set_name(buf, "Term" .. n)
				vim.keymap.set("n", "q", function()
					local win = find_buf_win(buf)
					if win then vim.api.nvim_win_close(win, false) end
				end, { buffer = buf })
				vim.keymap.set("n", "<S-h>", "<nop>", { buffer = buf })
				vim.keymap.set("n", "<S-l>", "<nop>", { buffer = buf })
				vim.keymap.set("n", "<leader>-", "<nop>", { buffer = buf })
				vim.keymap.set("n", "<leader>|", "<nop>", { buffer = buf })
				vim.cmd("stopinsert")
			end
		end

		-- Term1-9: bottom row terminals
		for i = 1, 9 do
			vim.api.nvim_create_user_command("Term" .. i, make_term_cmd(i, open_bottom_term_win), {})
		end

		-- Term10: right side, full height (28% width)
		local function open_right_term_win()
			vim.cmd("botright vsplit")
			vim.api.nvim_win_set_width(0, math.floor(vim.o.columns * 0.28))
		end
		vim.api.nvim_create_user_command("Term10", make_term_cmd(10, open_right_term_win), {})
	end,
}
