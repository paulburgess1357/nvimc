local M = {}

-- Binary-search line jump: hold Ctrl+Shift and tap j/k, the same way Alt+hjkl
-- drives window resizing. Rather than reading a relative line number and typing
-- a count, you answer "is my target above or below the cursor?" -- each press
-- halves the candidate range, so ceil(log2(visible lines)) presses pin any line
-- on screen and your eyes never leave the target.
--
-- There is no trigger key, so the first press does double duty: it carries a
-- direction AND seeds the range from wherever the cursor already is (up =>
-- w0..cursor-1, down => cursor+1..w$), which converges faster than always
-- starting from the middle.
--
-- The search is strictly confined to the lines visible when it started. If the
-- window scrolls, the target slides out from under your eyes and the range goes
-- stale, so scrolling ends the search rather than trying to follow it.

local ns = vim.api.nvim_create_namespace("bisect")

-- Live search, nil when idle:
--   { win, buf, lo, hi, pivot, topline, scrolloff }
local state = nil

-- Re-applied on colorscheme changes, which clear all highlight definitions.
local function define_hl()
	vim.api.nvim_set_hl(0, "BisectLine", { link = "Visual", default = true })
end

define_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = define_hl })

-- line_hl_group spans the full window width, including past end-of-line, which
-- hl_group on a text range would not.
local function mark(buf, line)
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	vim.api.nvim_buf_set_extmark(buf, ns, line - 1, 0, {
		line_hl_group = "BisectLine",
		priority = 200, -- above treesitter (100)
	})
end

-- A window-local scrolloff of -1 means "no local value, inherit the global", so
-- saving and restoring it verbatim keeps that inheritance intact.
local function set_scrolloff(win, value)
	pcall(vim.api.nvim_set_option_value, "scrolloff", value, { win = win, scope = "local" })
end

-- Single teardown path: every way a search can end routes through here.
local function stop()
	if not state then
		return
	end
	if vim.api.nvim_buf_is_valid(state.buf) then
		vim.api.nvim_buf_clear_namespace(state.buf, ns, 0, -1)
	end
	if vim.api.nvim_win_is_valid(state.win) then
		set_scrolloff(state.win, state.scrolloff)
	end
	state = nil
end

-- Begin a search over the visible window, already narrowed by `dir`.
local function start(win, buf, dir, cur)
	local top, bot = vim.fn.line("w0"), vim.fn.line("w$")
	local s = {
		win = win,
		buf = buf,
		topline = top,
		scrolloff = vim.api.nvim_get_option_value("scrolloff", { win = win, scope = "local" }),
	}
	if dir == "up" then
		s.lo, s.hi = top, math.max(top, cur - 1)
	else
		s.lo, s.hi = math.min(bot, cur + 1), bot
	end
	-- With scrolloff set, a pivot near the window edge would make Neovim scroll
	-- to keep context, which is exactly what must not happen here.
	set_scrolloff(win, 0)
	vim.cmd("normal! m'") -- jumplist entry, so <C-o> comes back
	return s
end

-- dir is "up" or "down". A search continues only while the cursor is still
-- sitting on the pivot we put it on; anything else starts over, which is what
-- makes a mistaken press recoverable by simply carrying on.
M.step = function(dir)
	local win = vim.api.nvim_get_current_win()
	local buf = vim.api.nvim_win_get_buf(win)
	local cur = vim.api.nvim_win_get_cursor(win)[1]

	local s = state
	if s and s.win == win and s.buf == buf and s.pivot == cur then
		-- The pivot itself is excluded: the answer was "strictly above/below".
		-- The clamps keep lo <= hi when you answer past the end of the range.
		if dir == "up" then
			s.hi = math.max(s.lo, cur - 1)
		else
			s.lo = math.min(s.hi, cur + 1)
		end
	else
		stop()
		s = start(win, buf, dir, cur)
	end

	local pivot = math.floor((s.lo + s.hi) / 2)
	local converged = s.lo >= s.hi

	-- Published before moving so the CursorMoved handler, which fires after this
	-- function returns, recognises the cursor as ours and leaves the search be.
	s.pivot = pivot
	state = s
	vim.api.nvim_win_set_cursor(win, { pivot, 0 })

	if converged then
		stop() -- landed; the cursor says everything the highlight would
	else
		mark(buf, pivot)
	end
end

-- Anything that moves the cursor, scrolls the window, or switches away ends the
-- search. Scrolling is checked by topline rather than by the event alone, since
-- WinScrolled also fires for resizes that leave the view intact.
vim.api.nvim_create_autocmd({ "CursorMoved", "BufLeave", "WinLeave", "WinScrolled" }, {
	callback = function()
		if not state then
			return
		end
		local win = vim.api.nvim_get_current_win()
		if win ~= state.win or not vim.api.nvim_win_is_valid(state.win) then
			return stop()
		end
		if vim.api.nvim_win_get_buf(win) ~= state.buf then
			return stop()
		end
		if vim.api.nvim_win_get_cursor(win)[1] ~= state.pivot or vim.fn.line("w0") ~= state.topline then
			return stop()
		end
	end,
})

return M
