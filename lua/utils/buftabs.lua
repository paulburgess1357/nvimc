local M = {}

-- Reorderable buffer tabs without a tabline plugin. Neovim has no notion of
-- buffer order beyond buffer numbers, and lualine's `buffers` component draws
-- in bufnr order. This module keeps its own ordered list of listed buffers;
-- plugin/ui/lualine.lua points the `buffers` component at it, and the
-- <S-h>/<S-l> cycle maps follow it too, so cycling always matches what the
-- tabline shows. The order lives in memory; utils.session saves/restores it.

-- Bufnrs in display order. Synced lazily by M.list().
local order = {}

-----------------------------------------------------------
-- Peek popup. There is no tabline (plugin/ui/lualine.lua), so cycling or
-- moving tabs pops a small float at the top right listing the tabs in order,
-- the current one in the mode color (LualineBufActive, set in lualine.lua).
-- It closes on the next key that is not one of the tab keys: Neovim never
-- sees key releases, so this is the closest thing to "while Shift is held".
-- A float, unlike toggling the tabline, does not shift the layout.
-----------------------------------------------------------
local PEEK_NS = vim.api.nvim_create_namespace("buftabs_peek")
local peek_keys = {}
for _, k in ipairs({ "<S-h>", "<S-l>", "<C-S-h>", "<C-S-l>" }) do
	peek_keys[vim.keycode(k)] = true
end
local peek_buf, peek_win

local function peek_close()
	vim.on_key(nil, PEEK_NS)
	if peek_win and vim.api.nvim_win_is_valid(peek_win) then vim.api.nvim_win_close(peek_win, true) end
	peek_win = nil
end

-- Lines and per-line highlight spans for the popup.
local function peek_lines(bufs)
	local cur = vim.api.nvim_get_current_buf()
	local ok, devicons = pcall(require, "nvim-web-devicons")
	local lines, hls, width = {}, {}, 1
	for i, buf in ipairs(bufs) do
		local path = vim.api.nvim_buf_get_name(buf)
		local name = vim.fn.fnamemodify(path, ":t")
		if name == "" then name = "[No Name]" end
		local icon, icon_hl = "", nil
		if ok then icon, icon_hl = devicons.get_icon(name, vim.fn.fnamemodify(path, ":e"), { default = true }) end
		local prefix = " " .. (icon or "") .. " "
		local line = prefix .. name .. (vim.bo[buf].modified and " ●" or "") .. " "
		lines[i] = line
		hls[i] = {
			{ 1, #prefix - 1, icon_hl },
			{ #prefix, #prefix + #name, buf == cur and "LualineBufActive" or "WinBarNC" },
		}
		width = math.max(width, vim.fn.strdisplaywidth(line))
	end
	return lines, hls, width
end

function M.peek()
	local bufs = M.list()
	if #bufs == 0 then return end
	local lines, hls, width = peek_lines(bufs)
	if not (peek_buf and vim.api.nvim_buf_is_valid(peek_buf)) then
		peek_buf = vim.api.nvim_create_buf(false, true)
		vim.bo[peek_buf].bufhidden = "wipe"
	end
	vim.api.nvim_buf_set_lines(peek_buf, 0, -1, false, lines)
	vim.api.nvim_buf_clear_namespace(peek_buf, PEEK_NS, 0, -1)
	for i, spans in ipairs(hls) do
		for _, span in ipairs(spans) do
			if span[3] then
				vim.api.nvim_buf_set_extmark(peek_buf, PEEK_NS, i - 1, span[1], { end_col = span[2], hl_group = span[3] })
			end
		end
	end
	local config = {
		relative = "editor",
		anchor = "NE",
		row = 0,
		col = vim.o.columns,
		width = width,
		height = #lines,
		style = "minimal",
		border = "rounded",
		focusable = false,
		zindex = 60,
	}
	if peek_win and vim.api.nvim_win_is_valid(peek_win) then
		vim.api.nvim_win_set_config(peek_win, config)
		return
	end
	peek_win = vim.api.nvim_open_win(peek_buf, false, config)
	vim.wo[peek_win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder"
	vim.on_key(function(key, typed)
		if peek_keys[typed ~= "" and typed or key] then return end
		peek_close()
	end, PEEK_NS)
end

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

-- File names in display order, for utils.session to save.
function M.names()
	return vim.tbl_map(vim.api.nvim_buf_get_name, M.list())
end

-- Re-apply a saved M.names() order. Unknown names are ignored; buffers not in
-- `names` keep their place after the ones that are.
function M.restore(names)
	local by_name = {}
	for _, buf in ipairs(M.list()) do
		by_name[vim.api.nvim_buf_get_name(buf)] = buf
	end
	order = {}
	for _, name in ipairs(names) do
		order[#order + 1] = by_name[name]
	end
	M.list()
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
	M.peek()
end

-- Move the current tab one slot right (dir = 1) / left (dir = -1). Stops at
-- the ends rather than wrapping.
function M.move(dir)
	local bufs = M.list()
	local i = current_index(bufs)
	local j = i and i + dir
	if not i or j < 1 or j > #bufs then return end
	bufs[i], bufs[j] = bufs[j], bufs[i]
	M.peek()
end

return M
