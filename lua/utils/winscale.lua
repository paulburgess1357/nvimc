-- Keep split proportions across layout changes.
--
-- With 'equalalways' off Neovim keeps every window's absolute size and
-- hands any difference to one window of a row or column: the last one when
-- a frame shrinks, the first one when it grows. That shows twice:
--
--   * On a screen resize (terminal window maximized or restored, font size
--     changed) a 70/30 layout drifts on every resize.
--   * When a window opens at the edge of a frame that holds other splits
--     (aerial or a dap-ui panel beside the files-over-terminals column, the
--     quickfix list under it) the space is taken from the frame's last
--     window and given back to its first, so toggling the panel walks width
--     from one split to another.
--
-- After each layout change the winlayout() tree is snapshotted with every
-- frame's share of its parent (widths within a row, heights within a
-- column) and, per frame, the exact sizes its children had at each size
-- the frame has been. After the next change (a window opened or closed,
-- the screen resized) every frame that still has the same children gets
-- those sizes back: the ones remembered for its new size when it has been
-- that size before and they still fit its current shares (so toggling a
-- panel is exact, with no rounding creep, while a resize made in between
-- is kept), else its shares against the new size. The frame whose
-- children changed, the one a window was added to or removed from, is
-- left as Neovim made it: a split still halves the window it splits and a
-- closed window still hands its space to its neighbour. Floats are not
-- part of winlayout().

local M = {}

local snap -- annotated layout tree from the last layout change
-- seen[frame key][frame size along its axis] = the children's sizes then.
local seen = {}

-- Annotated copy of a winlayout() node: kind ("leaf", "row" or "col"),
-- children, size and position (separators included), key (the sorted
-- windows it holds, which identifies a frame across layout changes) and
-- frac (each child's share of the parent's axis).
local function record(node)
	local kind, v = node[1], node[2]
	if kind == "leaf" then
		local pos = vim.api.nvim_win_get_position(v)
		return {
			kind = "leaf", win = v, key = tostring(v), row = pos[1], col = pos[2],
			w = vim.api.nvim_win_get_width(v), h = vim.api.nvim_win_get_height(v),
		}
	end
	local out = { kind = kind, children = {}, w = 0, h = 0, row = math.huge, col = math.huge }
	local wins, total = {}, 0
	for i, child in ipairs(v) do
		local c = record(child)
		out.children[i] = c
		out.row, out.col = math.min(out.row, c.row), math.min(out.col, c.col)
		if kind == "row" then
			out.w, out.h = out.w + c.w + (i > 1 and 1 or 0), math.max(out.h, c.h)
		else
			out.w, out.h = math.max(out.w, c.w), out.h + c.h + (i > 1 and 1 or 0)
		end
		total = total + (kind == "row" and c.w or c.h)
		for w in c.key:gmatch("%d+") do wins[#wins + 1] = tonumber(w) end
	end
	for _, c in ipairs(out.children) do
		local s = kind == "row" and c.w or c.h
		c.frac = total > 0 and s / total or 0
	end
	table.sort(wins)
	out.key = table.concat(wins, ",")
	return out
end

-- Every frame of a recorded tree, by key.
local function index(rec, out)
	out = out or {}
	out[rec.key] = rec
	for _, c in ipairs(rec.children or {}) do index(c, out) end
	return out
end

-- A window on the right (rows) or bottom (columns) edge of a frame: moving
-- that window's separator moves the frame's, like dragging it with the
-- mouse, which resizes the frame and its next sibling and nothing else.
local function edge_win(frame, kind)
	if frame.kind == "leaf" then return frame.win end
	for _, c in ipairs(frame.children) do
		local at_edge = kind == "row" and (c.col + c.w == frame.col + frame.w) or (c.row + c.h == frame.row + frame.h)
		if at_edge then return edge_win(c, kind) end
	end
	return edge_win(frame.children[#frame.children], kind)
end

-- The sizes the children of `cur` (a frame of the current layout) should
-- get, or nil to leave the frame alone. `rec` is the same frame in the
-- snapshot, if it existed then. Sizes remembered for the frame at its
-- current size win when the frame had no shape to compare with (it just
-- re-formed when a panel between its children closed) or when they still
-- agree with the recorded shares, within a cell each; a separator dragged
-- since then wins otherwise, and the shares are scaled to the new size.
local function targets(rec, cur)
	local size = cur.kind == "row" and cur.w or cur.h
	local exact = (seen[cur.key] or {})[size]
	if exact and #exact ~= #cur.children then exact = nil end
	if exact and rec then
		local sum = 0
		for _, e in ipairs(exact) do sum = sum + e end
		for i, e in ipairs(exact) do
			if math.abs(e - rec.children[i].frac * sum) > 1 then exact = nil break end
		end
	end
	if exact then return exact end
	if not rec then return nil end
	local total, out = size - (#cur.children - 1), {}
	for i, c in ipairs(rec.children) do out[i] = math.max(1, math.floor(c.frac * total + 0.5)) end
	return out
end

-- Size the children of `cur` to `want`: each child's separator is dragged
-- in turn; the last child takes the remainder.
local function apply(cur, want)
	for i = 1, #cur.children - 1 do
		local c = cur.children[i]
		local have = cur.kind == "row" and c.w or c.h
		if want[i] ~= have then
			local win = edge_win(c, cur.kind)
			if cur.kind == "row" then
				pcall(vim.fn.win_move_separator, win, want[i] - have)
			else
				pcall(vim.fn.win_move_statusline, win, want[i] - have)
			end
			-- The drag resized the next child too: re-read the frame.
			local fresh = record(vim.fn.winlayout())
			cur = index(fresh)[cur.key] or cur
		end
	end
	return cur
end

-- Walk the current layout; wherever a frame still has the children it had
-- in the snapshot (or re-formed with children it has held before), give
-- them their sizes back. Frames whose children changed are left alone, but
-- their unchanged descendants are still restored.
local function reconcile(old, cur)
	if cur.kind == "leaf" then return end
	local rec = old[cur.key]
	if rec and rec.kind == cur.kind and #rec.children == #cur.children then
		for i, c in ipairs(cur.children) do
			if rec.children[i].key ~= c.key then rec = nil break end
		end
	else
		rec = nil
	end
	local want = targets(rec, cur)
	if want then cur = apply(cur, want) end
	for _, c in ipairs(cur.children) do reconcile(old, c) end
end

-- Remember each frame's children's sizes at the frame's current size.
local function remember(rec)
	if rec.kind == "leaf" then return end
	local sizes = {}
	for i, c in ipairs(rec.children) do sizes[i] = rec.kind == "row" and c.w or c.h end
	seen[rec.key] = seen[rec.key] or {}
	seen[rec.key][rec.kind == "row" and rec.w or rec.h] = sizes
	for _, c in ipairs(rec.children) do remember(c) end
end

local function snapshot()
	snap = record(vim.fn.winlayout())
	remember(snap)
end

-- Restore the recorded shares of every frame that survived the last change,
-- then snapshot the result.
function M.rescale()
	if snap then reconcile(index(snap), record(vim.fn.winlayout())) end
	snapshot()
end

-- After a resize: if the set of windows changed since the snapshot (a
-- window opened with :noautocmd, as aerial's is, fires no WinNew, but the
-- windows it pushed aside still fire WinResized), restore the surviving
-- frames; otherwise the change is the new normal (the user dragged a
-- separator, a plugin resized its window) and is just snapshotted.
local function settle()
	if snap and snap.key ~= record(vim.fn.winlayout()).key then
		M.rescale()
	else
		snapshot()
	end
end

function M.setup()
	local group = vim.api.nvim_create_augroup("winscale", { clear = true })
	-- A window opened or closed: once the layout has settled (WinClosed
	-- fires before the window is gone), restore the surviving frames.
	vim.api.nvim_create_autocmd({ "WinNew", "WinClosed" }, {
		group = group,
		callback = function() vim.schedule(M.rescale) end,
	})
	vim.api.nvim_create_autocmd({ "VimEnter", "WinResized", "SessionLoadPost" }, {
		group = group,
		callback = function() vim.schedule(settle) end,
	})
	-- VimResized fires after Neovim redistributed the space but before the
	-- resulting WinResized, so `snap` still holds the old proportions.
	vim.api.nvim_create_autocmd("VimResized", { group = group, callback = M.rescale })
end

return M
