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

-- Opening/closing Term10 steals/returns width only at the layout's right
-- edge, so the rightmost bottom terminal absorbs the whole change while the
-- others keep their widths. Redistribute the bottom row evenly afterwards.
-- `extra` is a window in the row that has no terminal buffer yet (a split just
-- made by open_bottom_term_win) and must be counted too.
local function equalize_bottom_terms(extra)
	local wins = get_bottom_term_wins()
	if extra then
		table.insert(wins, { win = extra, num = 0 })
		table.sort(wins, function(a, b)
			return vim.api.nvim_win_get_position(a.win)[2] < vim.api.nvim_win_get_position(b.win)[2]
		end)
	end
	if #wins < 2 then return end
	local total = 0
	for _, tw in ipairs(wins) do
		total = total + vim.api.nvim_win_get_width(tw.win)
	end
	local each, rem = math.floor(total / #wins), total % #wins
	for i = 1, #wins - 1 do
		vim.api.nvim_win_set_width(wins[i].win, each + (i <= rem and 1 or 0))
	end
end

local function open_bottom_term_win(n)
	local wins = get_bottom_term_wins()
	local after, before
	for _, tw in ipairs(wins) do
		if tw.num < n then after = tw.win
		elseif tw.num > n then before = before or tw.win end
	end
	-- With equalalways off, a vsplit halves only the terminal it splits, so
	-- the row is re-equalized by hand after the new window is added.
	if after then
		vim.api.nvim_set_current_win(after)
		vim.cmd("vertical belowright split")
		equalize_bottom_terms(vim.api.nvim_get_current_win())
	elseif before then
		vim.api.nvim_set_current_win(before)
		vim.cmd("vertical aboveleft split")
		equalize_bottom_terms(vim.api.nvim_get_current_win())
	else
		vim.cmd("botright split")
		local bottom = vim.api.nvim_get_current_win()
		fix_term10_layout()
		vim.api.nvim_win_set_height(bottom, math.floor(vim.o.lines * 0.3))
	end
end

-- `botright vsplit` takes Term10's whole width from the rightmost column, so
-- one file split gets squashed while the others keep their size. Shrink every
-- pre-existing window proportionally instead.
local function open_right_term_win()
	local widths = {}
	for _, w in ipairs(vim.api.nvim_list_wins()) do
		widths[w] = vim.api.nvim_win_get_width(w)
	end
	vim.cmd("botright vsplit")
	local width = math.floor(vim.o.columns * 0.28)
	vim.api.nvim_win_set_width(0, width)
	local scale = 1 - (width + 1) / vim.o.columns
	for w, old in pairs(widths) do
		if vim.api.nvim_win_is_valid(w) then
			vim.api.nvim_win_set_width(w, math.floor(old * scale))
		end
	end
	vim.api.nvim_win_set_width(0, width)
	equalize_bottom_terms()
end

-- When Term10's window goes away (toggle, q, :q, or shell exit -- all funnel
-- through WinClosed) its width lands on the rightmost column only. Grow every
-- other window proportionally instead (the inverse of open_right_term_win),
-- then re-equalize the bottom row.
local suppress_layout = false
vim.api.nvim_create_autocmd("WinClosed", {
	callback = function(ev)
		local win = tonumber(ev.match)
		if suppress_layout or not (win and vim.api.nvim_win_is_valid(win)) then return end
		local buf = vim.api.nvim_win_get_buf(win)
		-- Closing a bottom terminal hands its width to one neighbour only.
		for n = 1, 9 do
			if term_bufs[n] == buf then
				vim.schedule(equalize_bottom_terms)
				return
			end
		end
		local buf10 = term_bufs[10]
		if buf10 and buf == buf10 then
			local scale = vim.o.columns / (vim.o.columns - vim.api.nvim_win_get_width(win) - 1)
			local widths = {}
			for _, w in ipairs(vim.api.nvim_list_wins()) do
				if w ~= win then widths[w] = vim.api.nvim_win_get_width(w) end
			end
			vim.schedule(function()
				for w, old in pairs(widths) do
					if vim.api.nvim_win_is_valid(w) then
						vim.api.nvim_win_set_width(w, math.floor(old * scale))
					end
				end
				equalize_bottom_terms()
			end)
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
	-- Term10 hosts streaming chat output: a terminal window only follows
	-- output while its cursor is on the last line. When leaving the window,
	-- snap to the end only if the view is already at the bottom (so following
	-- resumes even if the cursor drifted up a few lines). If scrolled up to
	-- read back, keep the position; output pauses until you return and hit G.
	if n == 10 then
		vim.api.nvim_create_autocmd("WinLeave", {
			buffer = buf,
			callback = function()
				local last = vim.api.nvim_buf_line_count(buf)
				if vim.fn.line("w$") >= last then
					pcall(vim.api.nvim_win_set_cursor, 0, { last, 0 })
				end
			end,
		})
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

-- Show Term<n>, spawning a shell if none exists. Never toggles it closed.
-- Leaves the terminal window current; callers move focus themselves.
-- Returns the buffer and whether a new shell was spawned. `cwd` (optional)
-- is the directory a newly spawned shell starts in.
local function ensure_term(n, cwd)
	local open_win_fn = n == 10 and open_right_term_win or open_bottom_term_win
	local buf = term_bufs[n]
	if buf and vim.api.nvim_buf_is_valid(buf) then
		local win = find_buf_win(buf)
		if win then
			vim.api.nvim_set_current_win(win)
		else
			open_win_fn(n)
			vim.api.nvim_set_current_buf(buf)
			if n == 10 then
				pcall(vim.api.nvim_win_set_cursor, 0, { vim.api.nvim_buf_line_count(buf), 0 })
			end
		end
		return buf, false
	end
	open_win_fn(n)
	if cwd then
		vim.cmd("enew")
		vim.fn.jobstart(vim.o.shell, { term = true, cwd = cwd })
	else
		vim.cmd("terminal")
	end
	buf = vim.api.nvim_get_current_buf()
	term_bufs[n] = buf
	vim.api.nvim_buf_set_name(buf, "Term" .. n)
	setup_term_buf(n, buf)
	vim.cmd("stopinsert")
	return buf, true
end

local function make_term_cmd(n)
	return function()
		local buf = term_bufs[n]
		local win = buf and vim.api.nvim_buf_is_valid(buf) and find_buf_win(buf)
		if win then
			-- pcall: closing fails if this is the last window (E444)
			pcall(vim.api.nvim_win_close, win, false)
		else
			ensure_term(n)
		end
	end
end

for i = 1, 10 do
	vim.api.nvim_create_user_command("Term" .. i, make_term_cmd(i), {})
end

vim.api.nvim_create_user_command("Term10Focus", function()
	ensure_term(10)
	vim.cmd("startinsert")
end, {})

-- Session support (utils.session): terminals can't be saved by :mksession,
-- so record which Term<n> windows are visible and each shell's directory,
-- and respawn fresh shells there on restore.
require("utils.session").term = {
	-- Close every terminal window without the WinClosed layout fix-ups, which
	-- would otherwise run after the session loads and resize its windows.
	close_all = function()
		suppress_layout = true
		for _, buf in pairs(term_bufs) do
			local win = vim.api.nvim_buf_is_valid(buf) and find_buf_win(buf)
			if win then pcall(vim.api.nvim_win_close, win, false) end
		end
		suppress_layout = false
	end,
	snapshot = function()
		local terms = {}
		for n, buf in pairs(term_bufs) do
			if vim.api.nvim_buf_is_valid(buf) and find_buf_win(buf) then
				local ok, pid = pcall(vim.fn.jobpid, vim.bo[buf].channel)
				local cwd = ok and vim.uv.fs_readlink("/proc/" .. pid .. "/cwd") or nil
				table.insert(terms, { n = n, cwd = cwd })
			end
		end
		table.sort(terms, function(a, b) return a.n < b.n end)
		return terms
	end,
	restore = function(terms)
		local origin = vim.api.nvim_get_current_win()
		for _, t in ipairs(terms) do
			local cwd = t.cwd and vim.fn.isdirectory(t.cwd) == 1 and t.cwd or vim.fn.getcwd()
			if type(t.n) == "number" and t.n >= 1 and t.n <= 10 then ensure_term(t.n, cwd) end
		end
		if vim.api.nvim_win_is_valid(origin) then vim.api.nvim_set_current_win(origin) end
	end,
}

-----------------------------------------------------------
-- :TermRun -- paste the current line / range into a terminal and press Enter
-----------------------------------------------------------
-- `:TermRun [n]` targets Term<n>, default settings.send_term (plugins.lua).
-- Nothing is interpreted: the text lands in whatever is in the terminal's
-- foreground, so a bash line runs in the shell and a python line runs in a
-- REPL you already started. Bound to <F9> (normal: cursor line, visual:
-- selection) in keymaps.lua, where a count picks the terminal: 3<F9>.

local function send_lines_to_term(lines, n)
	-- Drop leading/trailing blank lines; interior ones stay (a blank line
	-- ends a block in the python REPL, same as it would in a pasted file).
	while lines[1] and lines[1]:match("^%s*$") do table.remove(lines, 1) end
	while lines[#lines] and lines[#lines]:match("^%s*$") do table.remove(lines) end
	if #lines == 0 then return end

	-- Dedent by the common leading whitespace so a snippet indented inside a
	-- markdown code block doesn't reach the python REPL as an "unexpected
	-- indent". Relative indentation (python blocks) is preserved.
	local common
	for _, l in ipairs(lines) do
		if not l:match("^%s*$") then
			local indent = l:match("^[ \t]*")
			if not common or #indent < #common then common = indent end
		end
	end
	for i, l in ipairs(lines) do
		lines[i] = l:sub(#common + 1)
	end

	local text = table.concat(lines, "\r") .. "\r"
	-- An indented last line means a block is still open (python for/if/def):
	-- the REPL needs one more empty line to close and run it. Harmless for a
	-- shell, which just prints another prompt.
	if lines[#lines]:match("^[ \t]") then text = text .. "\r" end

	local origin = vim.api.nvim_get_current_win()
	local buf, created = ensure_term(n)
	-- A terminal window only follows new output while its cursor is on the
	-- last line; park it there before handing focus back to the file.
	pcall(vim.api.nvim_win_set_cursor, 0, { vim.api.nvim_buf_line_count(buf), 0 })
	if vim.api.nvim_win_is_valid(origin) then vim.api.nvim_set_current_win(origin) end

	local function send()
		if vim.api.nvim_buf_is_valid(buf) then
			vim.api.nvim_chan_send(vim.bo[buf].channel, text)
		end
	end
	-- A freshly spawned shell needs a moment before it reads its input.
	if created then vim.defer_fn(send, 200) else send() end
end

vim.api.nvim_create_user_command("TermRun", function(opts)
	local n = tonumber(opts.args) or settings.send_term or 1
	if n < 1 or n > 10 then
		vim.notify("TermRun: terminal must be 1-10", vim.log.levels.ERROR)
		return
	end
	send_lines_to_term(vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false), n)
	-- Advance past what was run (blank or not) so repeated <F9> walks down
	-- the file. Clamped at the last line.
	local last = vim.api.nvim_buf_line_count(0)
	local col = vim.api.nvim_win_get_cursor(0)[2]
	vim.api.nvim_win_set_cursor(0, { math.min(opts.line2 + 1, last), col })
end, { range = true, nargs = "?", desc = "Run line/range in Term<n> (default settings.send_term)" })

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
				{
					icon = "󰦛 ",
					key = "s",
					desc = "Restore Session",
					action = ":lua require('utils.session').restore()",
					enabled = function() return require("utils.session").exists() end,
				},
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
