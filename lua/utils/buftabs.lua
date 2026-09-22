local M = {}

-- Reorderable buffer tabs without a tabline plugin. Neovim has no notion of
-- buffer order beyond buffer numbers, and lualine's `buffers` component draws
-- in bufnr order. This module keeps its own ordered list of listed buffers;
-- plugin/ui/lualine.lua points the `buffers` component at it, and the
-- <S-h>/<S-l> cycle maps follow it too, so cycling always matches what the
-- tabline shows. The order lives in memory only (resets on restart).

-- Bufnrs in display order. Synced lazily by M.list().
local order = {}

local function is_tab(buf)
	return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted and vim.bo[buf].buftype ~= "quickfix"
end

-- Ordered bufnrs: drops buffers that went away, appends new ones at the end.
function M.list()
	local seen = {}
	local synced = {}
	for _, buf in ipairs(order) do
		if is_tab(buf) and not seen[buf] then
			seen[buf] = true
			synced[#synced + 1] = buf
		end
	end
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if is_tab(buf) and not seen[buf] then
			synced[#synced + 1] = buf
		end
	end
	order = synced
	return order
end

local function current_index(bufs)
	local cur = vim.api.nvim_get_current_buf()
	for i, buf in ipairs(bufs) do
		if buf == cur then return i end
	end
end

-- Switch to the next (dir = 1) / previous (dir = -1) tab, wrapping at the ends.
function M.cycle(dir)
	local bufs = M.list()
	local i = current_index(bufs)
	if not i then
		-- Current buffer is not a tab (unlisted, e.g. help): plain cycling
		vim.cmd(dir > 0 and "bnext" or "bprevious")
		return
	end
	if #bufs > 1 then
		vim.api.nvim_set_current_buf(bufs[(i - 1 + dir) % #bufs + 1])
	end
end

-- Move the current tab one slot right (dir = 1) / left (dir = -1). Stops at
-- the ends rather than wrapping.
function M.move(dir)
	local bufs = M.list()
	local i = current_index(bufs)
	local j = i and i + dir
	if not i or j < 1 or j > #bufs then return end
	bufs[i], bufs[j] = bufs[j], bufs[i]
	local ok, lualine = pcall(require, "lualine")
	if ok then lualine.refresh({ place = { "tabline" } }) end
end

return M
