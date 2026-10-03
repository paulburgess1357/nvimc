local M = {}

-- Terminal slots. `:Term<n>` toggles slot n; where it opens depends on n:
--
--   +-----------------------+--------+--------+
--   |                       | Term9  | Term10 |
--   |         files         |        |        |
--   |                       +--------+--------+
--   +-------+-------+-------+ Term7  | Term8  |
--   | Term1 |  ...  | Term6 |        |        |
--   +-------+-------+-------+--------+--------+
--
-- 1-6   bottom row under the files, left to right, equal widths.
-- 7-10  two full-height columns on the right: Term10 over Term8 at the far
--       right, Term9 over Term7 to its left. A column exists while either of
--       its terminals is visible; a lone terminal takes the whole column.
--       Both columns are always the same width.
--
-- Shells keep running while their window is closed. Sessions (utils.session)
-- save and restore which terminals are visible, their sizes, names and cwd.

local BOTTOM_MAX = 6
local BOTTOM_HEIGHT = 0.3 -- of the screen, for the bottom row
local COLS = { { 9, 7 }, { 10, 8 } } -- right columns, left to right; { top, bottom }
local COL_OF = { [9] = 1, [7] = 1, [10] = 2, [8] = 2 }
local PARTNER = { [9] = 7, [7] = 9, [10] = 8, [8] = 10 }
-- Width of each right column (of the screen), indexed by how many are open.
local COL_WIDTH = { 0.28, 0.22 }

-- 'scrollback' for the right-side terminals; set from settings.agent_scrollback.
local right_scrollback = 50000

local term_bufs = {} -- slot -> terminal buffer
local term_names = {} -- slot -> optional label, set with `:Term<n> <name>`
-- slot -> window opened for it that does not show its buffer yet. A fresh
-- split still displays the buffer it was split from, so while a slot is being
-- opened its window is tracked here rather than looked up by buffer.
local pending = {}
-- For <C-Space> (M.prev_window): the window the cursor was in before the
-- current one. `tracked_win` is the current non-floating window.
local prev_win, tracked_win

local function is_right(n)
	return n > BOTTOM_MAX
end

local function width(win)
	return vim.api.nvim_win_get_width(win)
end

local function height(win)
	return vim.api.nvim_win_get_height(win)
end

local function is_pending(win)
	for _, w in pairs(pending) do
		if w == win then return true end
	end
	return false
end

local function is_float(win)
	return vim.api.nvim_win_get_config(win).relative ~= ""
end

-- The layout window showing `buf`. Floats are skipped: the zoom window
-- (<leader><leader>z) shows a terminal's buffer without being its slot.
local function find_buf_win(buf)
	for _, w in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(w) == buf and not is_pending(w) and not is_float(w) then return w end
	end
end

-- Window showing Term<n> (or about to), nil if it is not on screen.
local function slot_win(n)
	local p = pending[n]
	if p and vim.api.nvim_win_is_valid(p) then return p end
	local buf = term_bufs[n]
	return buf and vim.api.nvim_buf_is_valid(buf) and find_buf_win(buf) or nil
end

-- A window of right column `c` (its top terminal if visible), or nil.
local function col_win(c)
	return slot_win(COLS[c][1]) or slot_win(COLS[c][2])
end

local function has_right()
	return (col_win(1) or col_win(2)) ~= nil
end

-- Non-floating windows of the current tab that are not right-column
-- terminals: the files, the bottom row, quickfix, ...
local function left_wins()
	local right = {}
	for n = BOTTOM_MAX + 1, 10 do
		local w = slot_win(n)
		if w then right[w] = true end
	end
	local wins = {}
	for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.api.nvim_win_get_config(w).relative == "" and not right[w] then wins[#wins + 1] = w end
	end
	return wins
end

-----------------------------------------------------------
-- Bottom row (Term1-6)
-----------------------------------------------------------
local function bottom_wins()
	local wins = {}
	for n = 1, BOTTOM_MAX do
		local w = slot_win(n)
		if w then wins[#wins + 1] = { win = w, num = n } end
	end
	return wins
end

-- With 'equalalways' off a vsplit halves only the terminal it splits, and a
-- closed terminal hands its width to one neighbour, so the row is spread
-- evenly by hand whenever it (or the space it sits in) changes.
local function equalize_bottom()
	local wins = bottom_wins()
	if #wins < 2 then return end
	local total = 0
	for _, tw in ipairs(wins) do
		total = total + width(tw.win)
	end
	local each, rem = math.floor(total / #wins), total % #wins
	for i = 1, #wins - 1 do
		vim.api.nvim_win_set_width(wins[i].win, each + (i <= rem and 1 or 0))
	end
end

-----------------------------------------------------------
-- Right columns (Term7-10): layout upkeep
-----------------------------------------------------------
local function col_widths()
	local c1, c2 = col_win(1), col_win(2)
	return { c1 and width(c1) or false, c2 and width(c2) or false }
end

-- Both columns equal: 28% when one is open, 22% each when both are.
local function default_col_widths()
	local c1, c2 = col_win(1), col_win(2)
	local count = (c1 and 1 or 0) + (c2 and 1 or 0)
	if count == 0 then return { false, false } end
	local w = math.floor(vim.o.columns * COL_WIDTH[count])
	return { c1 and w or false, c2 and w or false }
end

-- Everything left of the right columns: each window's width, plus the width
-- of the area as a whole. Taken before a change so `settle` can put the
-- windows back in the same proportions afterwards.
local function snapshot_left()
	local total = vim.o.columns
	for c = 1, 2 do
		local w = col_win(c)
		if w then total = total - width(w) - 1 end
	end
	local wins = {}
	for _, w in ipairs(left_wins()) do
		wins[#wins + 1] = { win = w, width = width(w), col = vim.api.nvim_win_get_position(w)[2] }
	end
	table.sort(wins, function(a, b) return a.col < b.col end)
	return { wins = wins, total = total }
end

-- Drag the two column separators so each open column is exactly its target
-- width. win_move_separator moves one specific divider (like the mouse), so
-- unlike nvim_win_set_width the columns can't steal from each other.
local function set_col_widths(targets)
	local inner, outer = col_win(1), col_win(2)
	if inner and outer and targets[2] then
		vim.fn.win_move_separator(inner, width(outer) - targets[2])
	end
	local first = inner or outer
	local target = targets[inner and 1 or 2]
	if not (first and target) then return end
	-- The divider on the columns' left edge is the right border of whichever
	-- left-area window reaches furthest right.
	local edge, reach = nil, -1
	for _, w in ipairs(left_wins()) do
		local r = vim.api.nvim_win_get_position(w)[2] + width(w)
		if r > reach then edge, reach = w, r end
	end
	if edge then vim.fn.win_move_separator(edge, width(first) - target) end
end

-- After the right side changed: give each column its target width, then
-- rescale the windows left of them proportionally. Without this the whole
-- change lands on the rightmost file window while the others keep their size.
local function settle(left, targets)
	set_col_widths(targets)
	local total = vim.o.columns
	for c = 1, 2 do
		local w = col_win(c)
		if w then total = total - width(w) - 1 end
	end
	local scale = total / math.max(left.total, 1)
	for _, s in ipairs(left.wins) do
		if vim.api.nvim_win_is_valid(s.win) then
			-- min(): a window that spanned the whole screen (quickfix) now spans
			-- only the left area.
			local want = math.min(math.floor(s.width * scale + 0.5), total)
			if width(s.win) ~= want then pcall(vim.api.nvim_win_set_width, s.win, want) end
		end
	end
	set_col_widths(targets)
	equalize_bottom()
end

-- Height of the top terminal in each stacked column, { [column] = height }.
local function stack_tops()
	local tops = {}
	for c = 1, 2 do
		local top, bot = slot_win(COLS[c][1]), slot_win(COLS[c][2])
		if top and bot then tops[c] = height(top) end
	end
	return tops
end

-- Put the right columns back in shape: each one full height, Term9's column
-- left of Term10's, bottom terminal stacked under the top one. Needed when a
-- column is added on the wrong side, and after anything that splits
-- `botright` (the first bottom terminal, :copen) and so cuts the columns
-- short. Each column's first window is moved out to a full-height split at
-- the far right; doing the inner column first and the outer one second leaves
-- them in order. nvim_win_set_config is used for the move rather than
-- `wincmd L`, which equalizes every window's size as a side effect.
--
-- `tops` (from stack_tops) is the height to give each stacked column's top
-- terminal. A `botright` split squeezes the bottom terminals, so callers that
-- can measure before the split pass it in; otherwise the current height is
-- used (the top terminal is normally untouched by the squeeze).
local function arrange_right(tops)
	local cur = vim.api.nvim_get_current_win()
	tops = tops or stack_tops()
	-- Safety net: put the left area's heights back if the move disturbed them.
	local heights = {}
	for _, w in ipairs(left_wins()) do
		heights[#heights + 1] = { win = w, height = height(w), row = vim.api.nvim_win_get_position(w)[1] }
	end
	table.sort(heights, function(a, b) return a.row < b.row end)
	for c = 1, 2 do
		local top, bot = slot_win(COLS[c][1]), slot_win(COLS[c][2])
		local first = top or bot
		if first then
			vim.api.nvim_win_set_config(first, { win = -1, split = "right" })
			if top and bot then vim.fn.win_splitmove(bot, top, { rightbelow = true }) end
		end
	end
	-- Heights last: moving the second column re-lays the first one.
	for c = 1, 2 do
		local top = slot_win(COLS[c][1])
		if top and slot_win(COLS[c][2]) and tops[c] then pcall(vim.api.nvim_win_set_height, top, tops[c]) end
	end
	for _, s in ipairs(heights) do
		if vim.api.nvim_win_is_valid(s.win) and height(s.win) ~= s.height then
			pcall(vim.api.nvim_win_set_height, s.win, s.height)
		end
	end
	if vim.api.nvim_win_is_valid(cur) then vim.api.nvim_set_current_win(cur) end
end

-- Full repair, keeping the current column widths.
local function repair_right()
	if not has_right() then return end
	local left, targets = snapshot_left(), col_widths()
	arrange_right()
	settle(left, targets)
end

-- :copen splits `botright` (full width), cutting the right columns short just
-- like the first bottom terminal does. 'filetype' is re-set on every :copen,
-- so FileType fires each time; location lists split below the current window
-- and never reach the columns.
local function on_quickfix()
	if vim.fn.win_gettype() == "quickfix" then vim.schedule(repair_right) end
end

-----------------------------------------------------------
-- Opening windows
-----------------------------------------------------------
local function open_bottom_win(n)
	local after, before
	for _, tw in ipairs(bottom_wins()) do
		if tw.num < n then
			after = tw.win
		elseif tw.num > n then
			before = before or tw.win
		end
	end
	if after or before then
		vim.api.nvim_set_current_win(after or before)
		vim.cmd(after and "vertical belowright split" or "vertical aboveleft split")
		pending[n] = vim.api.nvim_get_current_win()
		equalize_bottom()
		return
	end
	-- First bottom terminal: a full-width split, then pull the right columns
	-- back out to full height so the row sits under the files only.
	local left, targets, tops = snapshot_left(), col_widths(), stack_tops()
	vim.cmd("botright split")
	local win = vim.api.nvim_get_current_win()
	pending[n] = win
	if has_right() then
		arrange_right(tops)
		settle(left, targets)
	end
	vim.api.nvim_set_current_win(win)
	vim.api.nvim_win_set_height(win, math.floor(vim.o.lines * BOTTOM_HEIGHT))
end

local function open_right_win(n)
	local partner = slot_win(PARTNER[n])
	if partner then
		-- The column exists: share it, top slot above, bottom slot below.
		vim.api.nvim_set_current_win(partner)
		vim.cmd(COLS[COL_OF[n]][1] == n and "aboveleft split" or "belowright split")
		pending[n] = vim.api.nvim_get_current_win()
		return
	end
	-- New column. `botright vsplit` lands at the far right, which is wrong for
	-- Term9's column when Term10's is already there.
	local left = snapshot_left()
	vim.cmd("botright vsplit")
	local win = vim.api.nvim_get_current_win()
	pending[n] = win
	if COL_OF[n] == 1 and col_win(2) then arrange_right() end
	settle(left, default_col_widths())
	vim.api.nvim_set_current_win(win)
end

-----------------------------------------------------------
-- Closing: WinClosed covers the toggle, q, :q and shell exit alike
-----------------------------------------------------------
local suppress_layout = false

local function on_win_closed(ev)
	local win = tonumber(ev.match)
	if suppress_layout or not (win and vim.api.nvim_win_is_valid(win)) or is_float(win) then return end
	local buf = vim.api.nvim_win_get_buf(win)
	local slot
	for n, b in pairs(term_bufs) do
		if b == buf then slot = n end
	end
	if not slot then return end
	if not is_right(slot) then
		vim.schedule(equalize_bottom)
		return
	end
	-- A column that keeps its other terminal just gives it the full height.
	local partner = slot_win(PARTNER[slot])
	if partner and partner ~= win then return end
	-- The column is going away: its width would land on one neighbour only.
	local left = snapshot_left()
	vim.schedule(function()
		settle(left, default_col_widths())
	end)
end

-----------------------------------------------------------
-- Winbar: "Term<n> (name) · title". With globalstatus a terminal window
-- shows no name, so label it and show the live terminal title
-- (b:term_title: a running program, an agent's status).
-----------------------------------------------------------
local WINBAR_TAG = "%#Title#Term"

-- Winbar title segment. Only titles a program set are worth showing, so two
-- defaults are dropped: an idle shell's "user@host: path" (the prompt already
-- shows it) and Neovim's own "term://dir//pid:shell" seed, which is the title
-- until the shell prints its first prompt.
function _G.term_winbar_title()
	local title = vim.b.term_title or ""
	if title == "" or title:match("^term://") or title:match("^[^@%s]+@[^:%s]+:") then return "" end
	return " · " .. title
end

local function term_winbar(n)
	local name = term_names[n]
	local label = name and (" (" .. name:gsub("%%", "%%%%") .. ")") or ""
	return " " .. WINBAR_TAG .. n .. label .. "%*%<%{v:lua.term_winbar_title()}"
end

-- Label Term<n> and refresh its winbar if it is on screen.
local function set_term_name(n, name)
	term_names[n] = name
	local win = slot_win(n)
	if win then vim.wo[win].winbar = term_winbar(n) end
end

-----------------------------------------------------------
-- Terminal buffers
-----------------------------------------------------------
local function setup_term_buf(n, buf)
	vim.bo[buf].buflisted = false
	-- Agents print far more than a shell, and a narrow column wraps each line
	-- into several rows, so the right side gets a much deeper history.
	if is_right(n) then vim.bo[buf].scrollback = right_scrollback end
	vim.wo.winbar = term_winbar(n)
	-- The buffer gets a fresh window every time Term<n> is reopened.
	vim.api.nvim_create_autocmd("BufWinEnter", {
		buffer = buf,
		callback = function() vim.wo.winbar = term_winbar(n) end,
	})
	vim.keymap.set("n", "q", function()
		local w = find_buf_win(buf)
		-- pcall: closing fails if this is the last window (E444)
		if w then pcall(vim.api.nvim_win_close, w, false) end
	end, { buffer = buf })
	vim.keymap.set("n", "<Esc>", "<cmd>wincmd t<CR>", { buffer = buf })
	for _, key in ipairs({ "<S-h>", "<S-l>", "<leader>-", "<leader>|" }) do
		vim.keymap.set("n", key, "<nop>", { buffer = buf })
	end
	-- The right-side terminals host streaming output (agents, chat): a
	-- terminal window only follows output while its cursor is on the last
	-- line. When leaving the window, snap to the end only if the view is
	-- already at the bottom (so following resumes even if the cursor drifted
	-- up a few lines). If scrolled up to read back, keep the position; output
	-- pauses until you return and hit G.
	if is_right(n) then
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
			term_names[n] = nil
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
	local buf = term_bufs[n]
	local live = buf and vim.api.nvim_buf_is_valid(buf)
	if live then
		local win = find_buf_win(buf)
		if win then
			vim.api.nvim_set_current_win(win)
			return buf, false
		end
	end
	-- Opening the window hops through others (the neighbour it splits, the
	-- new split), each of which looks like "the previous window". Put the
	-- real origin back once the terminal's window is current.
	local origin = vim.api.nvim_get_current_win()
	local ok, err = pcall(is_right(n) and open_right_win or open_bottom_win, n)
	if not ok then
		pending[n] = nil
		error(err, 0)
	end
	if origin ~= vim.api.nvim_get_current_win() and not is_float(origin) then prev_win = origin end
	if live then
		vim.api.nvim_set_current_buf(buf)
		pending[n] = nil
		if is_right(n) then
			pcall(vim.api.nvim_win_set_cursor, 0, { vim.api.nvim_buf_line_count(buf), 0 })
		end
		return buf, false
	end
	if cwd then
		vim.cmd("enew")
		vim.fn.jobstart(vim.o.shell, { term = true, cwd = cwd })
	else
		vim.cmd("terminal")
	end
	buf = vim.api.nvim_get_current_buf()
	term_bufs[n] = buf
	pending[n] = nil
	vim.api.nvim_buf_set_name(buf, "Term" .. n)
	setup_term_buf(n, buf)
	vim.cmd("stopinsert")
	return buf, true
end

local function toggle_term(n)
	local win = slot_win(n)
	if win then
		-- pcall: closing fails if this is the last window (E444)
		pcall(vim.api.nvim_win_close, win, false)
	else
		ensure_term(n)
	end
end

-- Slot number for a `:Term` / `:TermRun` argument: a number 1-10 or a label
-- given with `:Term<n> <name>`. nil when it is neither.
local function resolve_term(arg)
	local n = tonumber(arg)
	if n then return (n >= 1 and n <= 10) and n or nil end
	for i, name in pairs(term_names) do
		if name == arg then return i end
	end
end

local function complete_term_names()
	local names = vim.tbl_values(term_names)
	table.sort(names)
	return names
end

-----------------------------------------------------------
-- Session support (utils.session): terminals can't be saved by :mksession,
-- so record which Term<n> windows are visible, each shell's directory, size
-- and name, and which terminal (if any) had focus, then respawn fresh shells
-- on restore. :mksession also can't point its final `wincmd w` at a skipped
-- terminal window, so `focus` is what puts the cursor back in it.
-----------------------------------------------------------

-- Terminals respawn at their default size, so put back what the snapshot
-- recorded: the column widths, the bottom row's height, the split inside
-- each stacked column, then each bottom terminal's width (all but the
-- rightmost, which absorbs the remainder).
local function restore_sizes(terms)
	local saved = {}
	for _, t in ipairs(terms) do
		if type(t.n) == "number" then saved[t.n] = t end
	end
	if has_right() then
		local targets = col_widths()
		for c = 1, 2 do
			for _, n in ipairs(COLS[c]) do
				if saved[n] and saved[n].width and slot_win(n) then targets[c] = saved[n].width end
			end
		end
		settle(snapshot_left(), targets)
	end
	local bottom = {}
	for _, tw in ipairs(bottom_wins()) do
		if saved[tw.num] then bottom[#bottom + 1] = { win = tw.win, t = saved[tw.num] } end
	end
	if bottom[1] and bottom[1].t.height then
		pcall(vim.api.nvim_win_set_height, bottom[1].win, bottom[1].t.height)
	end
	for c = 1, 2 do
		local top, bot = COLS[c][1], COLS[c][2]
		local win = slot_win(top)
		if win and slot_win(bot) and saved[top] and saved[top].height then
			pcall(vim.api.nvim_win_set_height, win, saved[top].height)
		end
	end
	for i = 1, #bottom - 1 do
		if bottom[i].t.width then pcall(vim.api.nvim_win_set_width, bottom[i].win, bottom[i].t.width) end
	end
end

local session_provider = {
	-- Close every terminal window without the WinClosed layout fix-ups, which
	-- would otherwise run after the session loads and resize its windows.
	close_all = function()
		suppress_layout = true
		for n in pairs(term_bufs) do
			local win = slot_win(n)
			if win then pcall(vim.api.nvim_win_close, win, false) end
		end
		suppress_layout = false
	end,
	snapshot = function()
		local terms = {}
		local cur_buf = vim.api.nvim_get_current_buf()
		for n, buf in pairs(term_bufs) do
			local win = slot_win(n)
			if win then
				local ok, pid = pcall(vim.fn.jobpid, vim.bo[buf].channel)
				local cwd = ok and vim.uv.fs_readlink("/proc/" .. pid .. "/cwd") or nil
				table.insert(terms, {
					n = n,
					cwd = cwd,
					name = term_names[n],
					focus = buf == cur_buf or nil,
					width = width(win),
					height = height(win),
				})
			end
		end
		table.sort(terms, function(a, b) return a.n < b.n end)
		return terms
	end,
	restore = function(terms)
		local origin = vim.api.nvim_get_current_win()
		local focus
		for _, t in ipairs(terms) do
			local cwd = t.cwd and vim.fn.isdirectory(t.cwd) == 1 and t.cwd or vim.fn.getcwd()
			if type(t.n) == "number" and t.n >= 1 and t.n <= 10 then
				ensure_term(t.n, cwd) -- leaves the terminal window current
				if type(t.name) == "string" then set_term_name(t.n, t.name) end
				if t.focus then focus = vim.api.nvim_get_current_win() end
			end
		end
		restore_sizes(terms)
		local target = focus or origin
		if vim.api.nvim_win_is_valid(target) then vim.api.nvim_set_current_win(target) end
	end,
}

-----------------------------------------------------------
-- :TermRun -- paste the current line / range into a terminal and press Enter
-----------------------------------------------------------
-- `:TermRun [n|name]` targets Term<n> or the terminal labelled <name>,
-- default settings.send_term (plugins.lua).
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

-----------------------------------------------------------
-- Previous window (<C-Space>, keymaps.lua)
-----------------------------------------------------------
-- Like <C-w>p -- press again to flip back -- but it also works while typing
-- in a terminal, lands in insert mode when the window it goes to is a
-- terminal, and tracks the window itself: floats (pickers, the zoom window)
-- never count as "previous", and neither do the windows a terminal hops
-- through while it is being opened. Does nothing if that window is gone.
function M.prev_window()
	local win = prev_win
	if not (win and win ~= vim.api.nvim_get_current_win() and vim.api.nvim_win_is_valid(win)) then return end
	-- Not both: a :stopinsert issued from terminal mode only takes effect
	-- after the mapping returns, and would cancel the :startinsert.
	if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "terminal" then
		vim.api.nvim_set_current_win(win)
		vim.cmd("startinsert")
	else
		vim.cmd("stopinsert")
		vim.api.nvim_set_current_win(win)
	end
end

-----------------------------------------------------------
-- Setup: commands and autocmds
-----------------------------------------------------------
function M.setup()
	local settings = require("config.plugins").settings or {}
	right_scrollback = settings.agent_scrollback or right_scrollback

	tracked_win = vim.api.nvim_get_current_win()
	vim.api.nvim_create_autocmd("WinEnter", {
		callback = function()
			local win = vim.api.nvim_get_current_win()
			if is_float(win) or win == tracked_win then return end
			prev_win, tracked_win = tracked_win, win
		end,
	})

	vim.api.nvim_create_autocmd("FileType", { pattern = "qf", callback = on_quickfix })
	vim.api.nvim_create_autocmd("WinClosed", { callback = on_win_closed })
	-- winbar is window-local: drop it if a non-terminal buffer lands in the window.
	vim.api.nvim_create_autocmd("BufWinEnter", {
		callback = function()
			if vim.bo.buftype ~= "terminal" and vim.wo.winbar:find(WINBAR_TAG, 1, true) then
				vim.wo.winbar = ""
			end
		end,
	})

	-- `:Term<n>` toggles the terminal. `:Term<n> <name>` never closes it: the
	-- terminal is shown (spawned or re-opened if needed) and labelled <name>.
	-- `:Term<n> -` does the same but clears the label.
	for n = 1, 10 do
		vim.api.nvim_create_user_command("Term" .. n, function(opts)
			if opts.args == "" then return toggle_term(n) end
			if not slot_win(n) then ensure_term(n) end
			set_term_name(n, opts.args ~= "-" and opts.args or nil)
		end, { nargs = "*" })
	end

	-- Lowercase `:term9` is the built-in `:terminal 9` ("run the shell command
	-- 9 in this window"), an easy slip for `:Term9`. User commands must start
	-- with a capital, so rewrite it instead -- only when it is the whole
	-- command typed so far. Plain `:term` / `:terminal` are left alone.
	for n = 1, 10 do
		local lower, upper = "term" .. n, "Term" .. n
		vim.keymap.set("ca", lower, function()
			return (vim.fn.getcmdtype() == ":" and vim.fn.getcmdline() == lower) and upper or lower
		end, { expr = true })
	end

	-- `:Term <name>` (or `:Term <n>`) toggles a terminal by its label, like Term<n>.
	vim.api.nvim_create_user_command("Term", function(opts)
		local n = resolve_term(opts.args)
		if not n then
			vim.notify("Term: no terminal named " .. opts.args, vim.log.levels.ERROR)
			return
		end
		toggle_term(n)
	end, { nargs = "+", complete = complete_term_names, desc = "Toggle terminal by name or number" })

	-- `:TermFocus [n|name]` shows the terminal (default Term10) and puts the
	-- cursor in it in insert mode. Unlike the toggle it never closes anything.
	-- Bound to <C-S-Space> in keymaps.lua, where a count picks the terminal.
	vim.api.nvim_create_user_command("TermFocus", function(opts)
		local n = 10
		if opts.args ~= "" then
			n = resolve_term(opts.args)
			if not n then
				vim.notify("TermFocus: no terminal 1-10 or named " .. opts.args, vim.log.levels.ERROR)
				return
			end
		end
		ensure_term(n)
		vim.cmd("startinsert")
	end, { nargs = "*", complete = complete_term_names, desc = "Focus Term<n|name> in insert mode (default Term10)" })
	vim.api.nvim_create_user_command("Term10Focus", "TermFocus 10", {})

	vim.api.nvim_create_user_command("TermRun", function(opts)
		local n = settings.send_term or 1
		if opts.args ~= "" then
			n = resolve_term(opts.args)
			if not n then
				vim.notify("TermRun: no terminal 1-10 or named " .. opts.args, vim.log.levels.ERROR)
				return
			end
		end
		send_lines_to_term(vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false), n)
		-- Advance past what was run (blank or not) so repeated <F9> walks down
		-- the file. Clamped at the last line.
		local last = vim.api.nvim_buf_line_count(0)
		local col = vim.api.nvim_win_get_cursor(0)[2]
		vim.api.nvim_win_set_cursor(0, { math.min(opts.line2 + 1, last), col })
	end, {
		range = true,
		nargs = "*",
		complete = complete_term_names,
		desc = "Run line/range in Term<n|name> (default settings.send_term)",
	})

	require("utils.session").term = session_provider
end

return M
