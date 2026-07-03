local M = {}

-- Intuitive window resizing: Alt+h/j/k/l moves the divider nearest to that
-- side of the current window in that direction (like dragging it with the
-- mouse). Uses win_move_separator()/win_move_statusline(), which move a
-- specific divider and handle nested frames correctly. Plain `:resize` on a
-- window redistributes space among its frame SIBLINGS first, so in nested
-- layouts (e.g. Term1/Term2 bottom row + Term10 right column) it can move an
-- unrelated inner divider instead of the one facing the neighbor.

-- Window id of the neighbor in direction "h"/"j"/"k"/"l", or nil.
local function neighbor(dir)
	local nr = vim.fn.winnr(dir)
	if nr == vim.fn.winnr() then
		return nil
	end
	return vim.fn.win_getid(nr)
end

M.intuitive_resize = function(direction, amount)
	if vim.fn.winnr("$") == 1 then
		vim.notify("Cannot resize - only one window open", vim.log.levels.INFO)
		return
	end

	if direction == "left" then
		-- Prefer moving our left divider (= right separator of the window on
		-- our left); if we are leftmost, pull our right divider left instead.
		local left = neighbor("h")
		if left then
			vim.fn.win_move_separator(left, -amount)
		elseif neighbor("l") then
			vim.fn.win_move_separator(0, -amount)
		end
	elseif direction == "right" then
		if neighbor("l") then
			vim.fn.win_move_separator(0, amount)
		else
			local left = neighbor("h")
			if left then
				vim.fn.win_move_separator(left, amount)
			end
		end
	elseif direction == "up" then
		-- Prefer moving our top divider (= statusline of the window above);
		-- if we are topmost, pull our bottom divider up instead.
		local above = neighbor("k")
		if above then
			vim.fn.win_move_statusline(above, -amount)
		elseif neighbor("j") then
			vim.fn.win_move_statusline(0, -amount)
		end
	elseif direction == "down" then
		if neighbor("j") then
			vim.fn.win_move_statusline(0, amount)
		else
			local above = neighbor("k")
			if above then
				vim.fn.win_move_statusline(above, amount)
			end
		end
	end
end

-- Helper functions for specific directions
for _, dir in ipairs({ "left", "right", "up", "down" }) do
	M["resize_" .. dir] = function(amount)
		M.intuitive_resize(dir, amount or 2)
	end
end

return M
