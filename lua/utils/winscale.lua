-- Keep split proportions across screen resizes (terminal window maximized
-- or restored, font size changed). Neovim keeps every window's absolute
-- size and hands the whole difference to the last window of each row or
-- column, and with 'equalalways' off nothing corrects that, so a 70/30
-- layout drifts on every resize.
--
-- After each layout change the winlayout() tree is snapshotted with every
-- frame's share of its parent (widths within a row, heights within a
-- column). On VimResized the same tree is walked again and each share is
-- reapplied against the new total. Floats are not part of winlayout().

local M = {}

local snap -- annotated layout tree from the last layout change

-- Width and height of a winlayout() node, separators included.
local function size(node)
	local kind, v = node[1], node[2]
	if kind == "leaf" then return vim.api.nvim_win_get_width(v), vim.api.nvim_win_get_height(v) end
	local w, h = 0, 0
	for i, child in ipairs(v) do
		local cw, ch = size(child)
		if kind == "row" then
			w, h = w + cw + (i > 1 and 1 or 0), math.max(h, ch)
		else
			w, h = math.max(w, cw), h + ch + (i > 1 and 1 or 0)
		end
	end
	return w, h
end

-- Copy of the tree with `frac` on each child: its share of the parent's axis.
local function record(node)
	local kind, v = node[1], node[2]
	if kind == "leaf" then return { kind = "leaf", win = v } end
	local sizes, total = {}, 0
	for i, child in ipairs(v) do
		local cw, ch = size(child)
		sizes[i] = kind == "row" and cw or ch
		total = total + sizes[i]
	end
	local out = { kind = kind, children = {} }
	for i, child in ipairs(v) do
		local c = record(child)
		c.frac = total > 0 and sizes[i] / total or 0
		out.children[i] = c
	end
	return out
end

local function snapshot()
	snap = record(vim.fn.winlayout())
end

-- First window inside a node. Setting its width/height sizes the whole
-- frame: a window in a column shares its width with its siblings.
local function first_win(node)
	if node[1] == "leaf" then return node[2] end
	return first_win(node[2][1])
end

-- True if `cur` (winlayout) still has the shape of `rec` (snapshot).
local function same_shape(rec, cur)
	if rec.kind ~= cur[1] then return false end
	if rec.kind == "leaf" then return rec.win == cur[2] end
	if #rec.children ~= #cur[2] then return false end
	for i, c in ipairs(rec.children) do
		if not same_shape(c, cur[2][i]) then return false end
	end
	return true
end

-- Give each child its recorded share of the node's current size. The last
-- child takes the rounding remainder.
local function apply(rec, cur)
	if rec.kind == "leaf" then return end
	local w, h = size(cur)
	local total = rec.kind == "row" and w or h
	local seps = #rec.children - 1
	for i, c in ipairs(rec.children) do
		if i < #rec.children then
			local want = math.max(1, math.floor(c.frac * (total - seps) + 0.5))
			local win = first_win(cur[2][i])
			if rec.kind == "row" then
				pcall(vim.api.nvim_win_set_width, win, want)
			else
				pcall(vim.api.nvim_win_set_height, win, want)
			end
		end
	end
	for i, c in ipairs(rec.children) do
		apply(c, cur[2][i])
	end
end

function M.rescale()
	if not snap then return end
	local cur = vim.fn.winlayout()
	if same_shape(snap, cur) then apply(snap, cur) end
	snapshot()
end

function M.setup()
	local group = vim.api.nvim_create_augroup("winscale", { clear = true })
	-- WinClosed fires before the window is gone: snapshot on the next tick.
	vim.api.nvim_create_autocmd({ "VimEnter", "WinNew", "WinClosed", "WinResized", "SessionLoadPost" }, {
		group = group,
		callback = function() vim.schedule(snapshot) end,
	})
	-- VimResized fires after Neovim redistributed the space but before the
	-- resulting WinResized, so `snap` still holds the old proportions.
	vim.api.nvim_create_autocmd("VimResized", { group = group, callback = M.rescale })
end

return M
