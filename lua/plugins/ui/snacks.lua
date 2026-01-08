-- Snacks.nvim: Dashboard, indent guides, bigfile handling, and custom terminals.
local plugins = require("config.plugins")
local cfg = plugins.snacks or {}
local settings = plugins.settings or {}

-----------------------------------------------------------
-- Dashboard gradient colors (adapts to colorscheme)
-----------------------------------------------------------
local function get_hl_fg(...)
	for _, name in ipairs({ ... }) do
		local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
		if hl.fg then return string.format("#%06x", hl.fg) end
	end
end

local gradient_hls = {
	{ "@keyword", "Keyword", "Statement" },
	{ "@function", "Function" },
	{ "@property", "@field", "Identifier" },
	{ "@string", "String" },
	{ "@type", "Type" },
	{ "@number", "@constant", "Constant", "Number" },
}

local function set_gradient_colors()
	for i, hls in ipairs(gradient_hls) do
		local color = get_hl_fg(unpack(hls)) or "#888888"
		vim.api.nvim_set_hl(0, "DashboardGradient" .. i, { fg = color })
	end
end

-----------------------------------------------------------
-- Dashboard header
-----------------------------------------------------------
local header_lines = {
	"███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
	"████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
	"██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
	"██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
	"██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
	"╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
}

local function make_header_sections()
	local sections = {}
	for i, line in ipairs(header_lines) do
		table.insert(sections, {
			text = { { line, hl = "DashboardGradient" .. i } },
			align = "center",
			padding = i == #header_lines and 1 or 0,
		})
	end
	table.insert(sections, { section = "keys", gap = 1, padding = 1 })
	return sections
end

-----------------------------------------------------------
-- Terminal management: Term1-9 (bottom), Term10 (right)
-----------------------------------------------------------
local term_bufs = {}

local function find_buf_win(buf)
	for _, w in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(w) == buf then return w end
	end
end

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

local function open_right_term_win()
	vim.cmd("botright vsplit")
	vim.api.nvim_win_set_width(0, math.floor(vim.o.columns * 0.28))
end

local function setup_term_buf(buf)
	vim.bo[buf].buflisted = false
	vim.keymap.set("n", "q", function()
		local w = find_buf_win(buf)
		if w then vim.api.nvim_win_close(w, false) end
	end, { buffer = buf })
	for _, key in ipairs({ "<S-h>", "<S-l>", "<leader>-", "<leader>|" }) do
		vim.keymap.set("n", key, "<nop>", { buffer = buf })
	end
end

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
		vim.api.nvim_buf_set_name(buf, "Term" .. n)
		setup_term_buf(buf)
		vim.cmd("stopinsert")
	end
end

local function register_term_commands()
	for i = 1, 9 do
		vim.api.nvim_create_user_command("Term" .. i, make_term_cmd(i, open_bottom_term_win), {})
	end
	vim.api.nvim_create_user_command("Term10", make_term_cmd(10, open_right_term_win), {})
end

-----------------------------------------------------------
-- Plugin spec
-----------------------------------------------------------
return {
	"folke/snacks.nvim",
	enabled = cfg.enabled ~= false,
	branch = cfg.branch,
	priority = 1000,
	lazy = false,
	opts = {
		bigfile = {
			enabled = true,
			notify = true,
			size = (settings.bigfile_max_mb or 1.5) * 1024 * 1024,
			setup = function()
				vim.cmd([[NoMatchParen]])
				vim.opt_local.swapfile = false
				vim.opt_local.foldmethod = "manual"
				vim.opt_local.undolevels = -1
				vim.opt_local.undoreload = 0
				vim.opt_local.list = false
			end,
		},
		dashboard = {
			enabled = true,
			preset = {
				keys = {
					{ icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
					{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
					{ icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
					{ icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
					{ icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
					{ icon = " ", key = "l", desc = "Lazy", action = ":Lazy" },
					{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
				},
			},
			sections = make_header_sections(),
		},
		indent = {
			enabled = true,
			indent = { char = "│", only_scope = false, only_current = false },
			scope = { enabled = true, char = "│", underline = false },
			animate = { enabled = true, duration = { step = 20, total = 300 } },
		},
		notifier = { enabled = false },
		scroll = { enabled = false },
		toggle = { enabled = true, which_key = true, notify = true },
	},
	init = function()
		set_gradient_colors()
		vim.api.nvim_create_autocmd("ColorScheme", { callback = set_gradient_colors })
		register_term_commands()
	end,
}
