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

		-- Terminal toggle commands (:Term1, :Term2, etc.)
		-- Store terminal buffers by number
		local term_bufs = {}

		-- Get terminal number from buffer
		local function get_term_num(buf)
			for num, b in pairs(term_bufs) do
				if b == buf then return num end
			end
			return nil
		end

		-- Find the right position for terminal n based on open terminals
		local function find_insert_position(n)
			local term_wins = {}
			for _, w in ipairs(vim.api.nvim_list_wins()) do
				local buf = vim.api.nvim_win_get_buf(w)
				local num = get_term_num(buf)
				if num then
					table.insert(term_wins, { win = w, num = num, col = vim.api.nvim_win_get_position(w)[2] })
				end
			end
			if #term_wins == 0 then return nil end

			-- Sort by column position
			table.sort(term_wins, function(a, b) return a.col < b.col end)

			-- Find where to insert: after the highest num < n, or before lowest num > n
			local insert_after = nil
			local insert_before = nil
			for _, tw in ipairs(term_wins) do
				if tw.num < n then
					insert_after = tw.win
				elseif tw.num > n and not insert_before then
					insert_before = tw.win
				end
			end

			return insert_after, insert_before
		end

		local function toggle_term(n)
			return function()
				local buf = term_bufs[n]

				-- If buffer exists and is valid, toggle its window
				if buf and vim.api.nvim_buf_is_valid(buf) then
					-- Find window showing this buffer
					for _, w in ipairs(vim.api.nvim_list_wins()) do
						if vim.api.nvim_win_get_buf(w) == buf then
							-- Window exists, close it (toggle off)
							vim.api.nvim_win_close(w, false)
							return
						end
					end
					-- Buffer exists but no window, reopen in correct position
					local insert_after, insert_before = find_insert_position(n)
					if insert_after then
						vim.api.nvim_set_current_win(insert_after)
						vim.cmd("vertical belowright split")
					elseif insert_before then
						vim.api.nvim_set_current_win(insert_before)
						vim.cmd("vertical aboveleft split")
					else
						vim.cmd("botright split | resize " .. math.floor(vim.o.lines * 0.3))
					end
					vim.api.nvim_set_current_buf(buf)
					return
				end

				-- Create new terminal in correct position
				local insert_after, insert_before = find_insert_position(n)
				if insert_after then
					vim.api.nvim_set_current_win(insert_after)
					vim.cmd("vertical belowright split")
				elseif insert_before then
					vim.api.nvim_set_current_win(insert_before)
					vim.cmd("vertical aboveleft split")
				else
					-- No terminals yet, create bottom split
					vim.cmd("botright split | resize " .. math.floor(vim.o.lines * 0.3))
				end

				vim.cmd("terminal")
				buf = vim.api.nvim_get_current_buf()
				term_bufs[n] = buf
				-- Set buffer name for lualine
				vim.api.nvim_buf_set_name(buf, "Term" .. n)
				vim.cmd("stopinsert")
			end
		end
		for i = 1, 9 do
			vim.api.nvim_create_user_command("Term" .. i, toggle_term(i), { desc = "Toggle terminal " .. i })
		end

		-- Term10: Full-height terminal on the right side (20% width)
		local term10_buf = nil
		local function open_term10_window()
			vim.cmd("botright vsplit")
			local width = math.floor(vim.o.columns * 0.28)
			vim.api.nvim_win_set_width(0, width)
		end

		vim.api.nvim_create_user_command("Term10", function()
			-- If buffer exists and is valid, toggle its window
			if term10_buf and vim.api.nvim_buf_is_valid(term10_buf) then
				for _, w in ipairs(vim.api.nvim_list_wins()) do
					if vim.api.nvim_win_get_buf(w) == term10_buf then
						vim.api.nvim_win_close(w, false)
						return
					end
				end
				-- Buffer exists but no window, reopen on right
				open_term10_window()
				vim.api.nvim_set_current_buf(term10_buf)
				return
			end

			-- Create new terminal on right side, full height
			open_term10_window()
			vim.cmd("terminal")
			term10_buf = vim.api.nvim_get_current_buf()
			vim.api.nvim_buf_set_name(term10_buf, "Term10")
			vim.cmd("stopinsert")
		end, { desc = "Toggle terminal 10 (right, full height)" })
	end,
}
