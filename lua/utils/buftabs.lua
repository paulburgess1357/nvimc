local M = {}

-- Buffer tabs without a tabline. This module keeps an ordered list of listed
-- buffers (open order, kept stable as buffers come and go): the <S-k>/<S-j>
-- cycle maps follow it, and the peek popup below shows it. The order lives
-- in memory; utils.session saves/restores it. In a terminal window the same
-- keys walk the Term slots instead (utils.terms), from normal mode.

-- Bufnrs in display order. Synced lazily by M.list().
local order = {}

-----------------------------------------------------------
-- Peek popup. There is no tabline (showtabline=0 in options.lua), so cycling
-- tabs pops a small float at the top left of the current window listing
-- the tabs in order, the current one on a highlighted line like mini.files.
-- It closes on the next key that is not one of the tab keys: Neovim never
-- sees key releases, so this is the closest thing to "while Shift is held".
-- A float, unlike toggling the tabline, does not shift the layout.
-----------------------------------------------------------
local PEEK_NS = vim.api.nvim_create_namespace("buftabs_peek")
local peek_keys = {}
for _, k in ipairs({ "<S-j>", "<S-k>" }) do
	peek_keys[vim.keycode(k)] = true
end
local peek_buf, peek_win

local function peek_close()
	vim.on_key(nil, PEEK_NS)
	if peek_win and vim.api.nvim_win_is_valid(peek_win) then vim.api.nvim_win_close(peek_win, true) end
	peek_win = nil
end

local function in_terminal()
	return vim.bo.buftype == "terminal"
end

-- Always show "parent/tail" in the popup, not only on collisions.
-- Toggle: <leader><leader>p (plugin/ui/whichkey.lua).
M.show_parent = false

-- Display names: the file's tail (or "parent/tail" with M.show_parent), with
-- more parents added when several buffers share a name, until they differ.
local function peek_names(bufs)
	local paths, parts, names = {}, {}, {}
	for i, buf in ipairs(bufs) do
		paths[i] = vim.api.nvim_buf_get_name(buf)
		parts[i] = vim.split(paths[i], "/", { trimempty = true })
		names[i] = parts[i][#parts[i]] or "[No Name]"
	end
	local function widen(i, depth)
		if #parts[i] > depth then
			names[i] = table.concat(parts[i], "/", #parts[i] - depth)
			return true
		end
	end
	local depth = 0
	if M.show_parent then
		depth = 1
		for i in ipairs(bufs) do widen(i, depth) end
	end
	for _ = 1, 10 do
		depth = depth + 1
		local count = {}
		for _, n in ipairs(names) do count[n] = (count[n] or 0) + 1 end
		local changed = false
		for i, n in ipairs(names) do
			if count[n] > 1 and widen(i, depth) then changed = true end
		end
		if not changed then break end
	end
	return names
end

-- Popup entries for the window kind: files (utils.buftabs order) in a file
-- window, Term slots (utils.terms) in a terminal window. Each entry is
-- { name, icon, icon_hl, modified, current }.
local function file_entries()
	local cur = vim.api.nvim_get_current_buf()
	local bufs = M.list()
	local ok, devicons = pcall(require, "nvim-web-devicons")
	local names = peek_names(bufs)
	local out = {}
	for i, buf in ipairs(bufs) do
		local icon, icon_hl = "", nil
		if ok then
			icon, icon_hl = devicons.get_icon(names[i], vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":e"), { default = true })
		end
		out[i] = { name = names[i], icon = icon, icon_hl = icon_hl, modified = vim.bo[buf].modified, current = buf == cur }
	end
	return out
end

local function term_entries()
	local cur = vim.api.nvim_get_current_buf()
	local out = {}
	for i, slot in ipairs(require("utils.terms").slots()) do
		out[i] = { name = slot.label, icon = "", current = slot.buf == cur }
	end
	return out
end

local function entries()
	return in_terminal() and term_entries() or file_entries()
end

-- Lines and per-line highlight spans for the popup.
local function peek_lines(items)
	local lines, hls, width = {}, {}, 1
	for i, item in ipairs(items) do
		local prefix = " " .. (item.icon or "") .. " "
		local line = prefix .. item.name .. (item.modified and " ●" or "") .. " "
		lines[i] = line
		-- Names in plain text; the current entry is marked by the cursor line
		-- (MiniFilesCursorLine, the same look as mini.files), set in M.peek.
		hls[i] = { { 1, #prefix - 1, item.icon_hl } }
		width = math.max(width, vim.fn.strdisplaywidth(line))
	end
	return lines, hls, width
end

function M.peek()
	local items = entries()
	if #items == 0 then return end
	local lines, hls, width = peek_lines(items)
	-- Titled like mini.files (FloatTitle, left, padded); never narrower than
	-- the title, which is wider than a short list of Term<n> entries.
	local title = in_terminal() and " Terminals " or " Buffers "
	width = math.max(width, vim.fn.strdisplaywidth(title))
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
		relative = "win",
		win = vim.api.nvim_get_current_win(),
		anchor = "NW",
		row = 0,
		col = 0,
		width = width,
		height = #lines,
		style = "minimal",
		title = title,
		title_pos = "left",
		border = (require("config.plugins").settings or {}).border or "single",
		focusable = false,
		zindex = 60,
	}
	local current = 1
	for i, item in ipairs(items) do
		if item.current then current = i end
	end
	if peek_win and vim.api.nvim_win_is_valid(peek_win) then
		vim.api.nvim_win_set_config(peek_win, config)
		vim.api.nvim_win_set_cursor(peek_win, { current, 0 })
		return
	end
	peek_win = vim.api.nvim_open_win(peek_buf, false, config)
	vim.wo[peek_win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:MiniFilesCursorLine"
	vim.wo[peek_win].cursorline = true
	vim.api.nvim_win_set_cursor(peek_win, { current, 0 })
	vim.on_key(function(key, typed)
		if peek_keys[typed ~= "" and typed or key] then return end
		peek_close()
		-- Landed in a terminal: go back to typing. The closing key is
		-- swallowed so it does not run as a normal-mode command first.
		-- startinsert is deferred: issued from inside on_key it only takes
		-- effect after the NEXT normal command, which would drop the cursor
		-- into the shell right after the next <S-j>/<S-k> opened the popup.
		if in_terminal() then
			vim.schedule(function()
				if in_terminal() then vim.cmd("startinsert") end
			end)
			return ""
		end
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

-- Switch to the next (dir = 1) / previous (dir = -1) tab, wrapping at the
-- ends. The first press only opens the peek popup, so you can see the tabs
-- before moving; presses while it is open switch.
function M.cycle(dir)
	if not (peek_win and vim.api.nvim_win_is_valid(peek_win)) then
		M.peek()
		return
	end
	if in_terminal() then
		-- Terminal window: walk the Term slots, focusing the chosen one in
		-- normal mode (its window is opened if hidden). The popup follows.
		local terms = require("utils.terms")
		local slots = terms.slots()
		local cur = vim.api.nvim_get_current_buf()
		for i, slot in ipairs(slots) do
			if slot.buf == cur then
				if #slots > 1 then terms.focus(slots[(i - 1 + dir) % #slots + 1].n) end
				M.peek()
				return
			end
		end
		return
	end
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

return M
