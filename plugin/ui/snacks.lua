local plugins = require("config.plugins")
local cfg = plugins.snacks or {}
local settings = plugins.settings or {}
if cfg.enabled == false then return end

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

-- Term10 must always be a full-height right column. `botright split` (used
-- for the first bottom terminal) spans the full width and cuts it short, so
-- push Term10 back to the far right and restore its width afterwards.
local function fix_term10_layout()
	local buf = term_bufs[10]
	if not (buf and vim.api.nvim_buf_is_valid(buf)) then return end
	local win = find_buf_win(buf)
	if not win then return end
	local cur = vim.api.nvim_get_current_win()
	vim.api.nvim_set_current_win(win)
	vim.cmd("wincmd L")
	vim.api.nvim_win_set_width(win, math.floor(vim.o.columns * 0.28))
	if vim.api.nvim_win_is_valid(cur) then
		vim.api.nvim_set_current_win(cur)
	end
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
		vim.cmd("botright split")
		local bottom = vim.api.nvim_get_current_win()
		fix_term10_layout()
		vim.api.nvim_win_set_height(bottom, math.floor(vim.o.lines * 0.3))
	end
end

-- Opening/closing Term10 steals/returns width only at the layout's right
-- edge, so the rightmost bottom terminal absorbs the whole change while the
-- others keep their widths. Redistribute the bottom row evenly afterwards.
local function equalize_bottom_terms()
	local wins = get_bottom_term_wins()
	if #wins < 2 then return end
	local total = 0
	for _, tw in ipairs(wins) do
		total = total + vim.api.nvim_win_get_width(tw.win)
	end
	local each = math.floor(total / #wins)
	for i = 1, #wins - 1 do
		vim.api.nvim_win_set_width(wins[i].win, each)
	end
end

local function open_right_term_win()
	vim.cmd("botright vsplit")
	vim.api.nvim_win_set_width(0, math.floor(vim.o.columns * 0.28))
	equalize_bottom_terms()
end

-- Re-equalize the bottom row when Term10's window goes away (toggle, q,
-- :q, or shell exit -- all funnel through WinClosed).
vim.api.nvim_create_autocmd("WinClosed", {
	callback = function(ev)
		local win = tonumber(ev.match)
		local buf10 = term_bufs[10]
		if buf10 and win and vim.api.nvim_win_is_valid(win)
			and vim.api.nvim_win_get_buf(win) == buf10 then
			vim.schedule(equalize_bottom_terms)
		end
	end,
})

local function setup_term_buf(n, buf)
	vim.bo[buf].buflisted = false
	vim.keymap.set("n", "q", function()
		local w = find_buf_win(buf)
		-- pcall: closing fails if this is the last window (E444)
		if w then pcall(vim.api.nvim_win_close, w, false) end
	end, { buffer = buf })
	vim.keymap.set("n", "<Esc>", "<cmd>wincmd t<CR>", { buffer = buf })
	for _, key in ipairs({ "<S-h>", "<S-l>", "<leader>-", "<leader>|" }) do
		vim.keymap.set("n", key, "<nop>", { buffer = buf })
	end
	-- When the shell exits (any status), drop the dead buffer and free the
	-- slot so the next Term<n> starts a fresh shell instead of reopening
	-- "[Process exited N]".
	vim.api.nvim_create_autocmd("TermClose", {
		buffer = buf,
		callback = function()
			term_bufs[n] = nil
			vim.schedule(function()
				if vim.api.nvim_buf_is_valid(buf) then
					pcall(vim.api.nvim_buf_delete, buf, { force = true })
				end
			end)
		end,
	})
end

local function make_term_cmd(n, open_win_fn)
	return function()
		local buf = term_bufs[n]
		if buf and vim.api.nvim_buf_is_valid(buf) then
			local win = find_buf_win(buf)
			if win then
				-- pcall: closing fails if this is the last window (E444)
				pcall(vim.api.nvim_win_close, win, false)
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
		setup_term_buf(n, buf)
		vim.cmd("stopinsert")
	end
end

for i = 1, 9 do
	vim.api.nvim_create_user_command("Term" .. i, make_term_cmd(i, open_bottom_term_win), {})
end
vim.api.nvim_create_user_command("Term10", make_term_cmd(10, open_right_term_win), {})

vim.api.nvim_create_user_command("Term10Focus", function()
	local buf = term_bufs[10]
	if buf and vim.api.nvim_buf_is_valid(buf) then
		local win = find_buf_win(buf)
		if win then
			vim.api.nvim_set_current_win(win)
		else
			open_right_term_win()
			vim.api.nvim_set_current_buf(buf)
		end
	else
		open_right_term_win()
		vim.cmd("terminal")
		buf = vim.api.nvim_get_current_buf()
		term_bufs[10] = buf
		vim.api.nvim_buf_set_name(buf, "Term10")
		setup_term_buf(10, buf)
	end
	vim.cmd("startinsert")
end, {})

-----------------------------------------------------------
-- Setup
-----------------------------------------------------------
set_gradient_colors()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_gradient_colors })

require("snacks").setup({
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
				{ icon = "󰋚 ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
				{ icon = "󰒓 ", key = "c", desc = "Config", action = ":e " .. vim.fn.stdpath("config") .. "/lua/config/plugins.lua" },
				{ icon = "󰚰 ", key = "u", desc = "Update Plugins", action = ":lua vim.pack.update()" },
				{ icon = "󰏖 ", key = "p", desc = "Browse Plugins", action = ":lua vim.pack.update(nil, { offline = true })" },
				{ icon = "󰓙 ", key = "h", desc = "Health Check", action = ":checkhealth" },
				{ icon = "󰩈 ", key = "q", desc = "Quit", action = ":qa" },
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
})
