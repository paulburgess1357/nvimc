local M = {}

-- Buffer tabs without a tabline. This module keeps an ordered list of listed
-- buffers (open order, kept stable as buffers come and go): the <S-k>/<S-j>
-- cycle maps follow it, and the peek popup below shows it. The order lives
-- in memory; utils.session saves/restores it. In a terminal window the same
-- keys walk the Term slots instead (utils.terms), from normal mode.

-- Bufnrs in display order. Synced lazily by M.list().
local order = {}

-----------------------------------------------------------
-- Peek popup. There is no tabline (showtabline=0 in options.lua), so
-- <S-j>/<S-k> pop a small float at the top left of the current window
-- listing the tabs in order (the Term slots in a terminal window), the
-- current one on a highlighted line like mini.files. It is modal: j/k (or
-- <S-j>/<S-k>) move the highlight, <CR>/<S-CR>/l/L switch to the highlighted entry,
-- <Esc>/q cancel, / filters by substring (then only <CR>/<S-CR>/<Esc> act),
-- and every other key is swallowed. Nothing changes until you choose, so
-- browsing terminals does not move focus or open hidden slots. A float,
-- unlike toggling the tabline, does not shift the layout.
-----------------------------------------------------------
local PEEK_NS = vim.api.nvim_create_namespace("buftabs_peek")
local peek_buf, peek_win
local peek_items, peek_sel -- entries shown, index of the highlighted one

local function peek_close()
	if peek_win and vim.api.nvim_win_is_valid(peek_win) then vim.api.nvim_win_close(peek_win, true) end
	peek_win, peek_items, peek_sel = nil, nil, nil
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
		out[i] = { buf = buf, name = names[i], icon = icon, icon_hl = icon_hl, modified = vim.bo[buf].modified, current = buf == cur }
	end
	return out
end

local function term_entries()
	local cur = vim.api.nvim_get_current_buf()
	local out = {}
	for i, slot in ipairs(require("utils.terms").slots()) do
		out[i] = { slot = slot.n, name = slot.label, icon = "", current = slot.buf == cur }
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

-- Draw (or redraw) the popup from peek_all, applying the filter. The
-- highlight goes to the first match while filtering.
local peek_all, peek_filter -- every entry; filter text (nil = not filtering)

local function peek_render()
	local items = peek_all
	if peek_filter then
		items = {}
		local pat = peek_filter:lower()
		for _, item in ipairs(peek_all) do
			if item.name:lower():find(pat, 1, true) then items[#items + 1] = item end
		end
	end
	peek_items = items
	if peek_sel > #items then peek_sel = math.max(1, #items) end
	local lines, hls, width = peek_lines(items)
	if #lines == 0 then lines, width = { " (no match) " }, 12 end
	-- Titled like mini.files (FloatTitle, left, padded); never narrower than
	-- the title, which is wider than a short list of Term<n> entries.
	local title = (in_terminal() and " Terminals" or " Buffers") .. (peek_filter and (" /" .. peek_filter) or "") .. " "
	width = math.max(width, vim.fn.strdisplaywidth(title))
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
	if peek_win and vim.api.nvim_win_is_valid(peek_win) then
		vim.api.nvim_win_set_config(peek_win, config)
	else
		peek_win = vim.api.nvim_open_win(peek_buf, false, config)
		vim.wo[peek_win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:MiniFilesCursorLine"
		vim.wo[peek_win].cursorline = true
	end
	vim.api.nvim_win_set_cursor(peek_win, { peek_sel, 0 })
end

-- Open the popup and read keys until a choice or a cancel. Keys come from
-- getcharstr(), which bypasses mappings: with on_key the / and n maps in
-- keymaps.lua (literal search, nzzzv) fired underneath the popup.
function M.peek()
	local items = entries()
	if #items == 0 then return end
	if not (peek_buf and vim.api.nvim_buf_is_valid(peek_buf)) then
		peek_buf = vim.api.nvim_create_buf(false, true)
		vim.bo[peek_buf].bufhidden = "wipe"
	end
	peek_all, peek_filter, peek_sel = items, nil, 1
	for i, item in ipairs(items) do
		if item.current then peek_sel = i end
	end
	peek_render()

	local chosen
	while true do
		vim.cmd.redraw()
		local ok, k = pcall(vim.fn.getcharstr)
		if not ok then break end -- <C-c>
		local name = vim.fn.keytrans(k)
		-- j/k move; J/K too since Shift is still held from <S-j>/<S-k> (while
		-- filtering j/k are text). <S-CR> is its own key only in terminals
		-- that report it (kitty); elsewhere it is a plain <CR>, handled anyway.
		local move = ({ J = 1, K = -1 })[k] or (not peek_filter and ({ j = 1, k = -1 })[k])
		if move then
			if #peek_items > 0 then
				peek_sel = (peek_sel - 1 + move) % #peek_items + 1
				vim.api.nvim_win_set_cursor(peek_win, { peek_sel, 0 })
			end
		elseif name == "<CR>" or name == "<S-CR>" or name == "<NL>" then
			chosen = peek_items[peek_sel]
			break
		elseif name == "<Esc>" then
			break
		elseif peek_filter then
			-- Filtering (after /): typed characters narrow the list by plain
			-- substring, <BS> deletes; deleting past the start leaves filtering.
			if name == "<BS>" then
				peek_filter = peek_filter ~= "" and peek_filter:sub(1, -2) or nil
				peek_sel = 1
				peek_render()
			elseif #k == 1 and k:match("[%g ]") then
				peek_filter = peek_filter .. k
				peek_sel = 1
				peek_render()
			end
		elseif k == "/" then
			peek_filter, peek_sel = "", 1
			peek_render()
		elseif k == "l" or k == "L" then -- L: still holding Shift
			chosen = peek_items[peek_sel]
			break
		elseif k == "q" then
			break
		end
		-- anything else: swallowed (modal)
	end
	peek_close()
	if chosen then
		M.switch_to(chosen)
	elseif in_terminal() then
		-- The terminal was in normal mode for the popup: back to typing.
		vim.cmd("startinsert")
	end
end

-- Go to a popup entry: a file switches the current window's buffer, a Term
-- slot focuses its window (opened if hidden) and starts typing there.
function M.switch_to(item)
	if not item then return end
	if item.slot then
		require("utils.terms").focus(item.slot)
		vim.cmd("startinsert")
	elseif item.buf and vim.api.nvim_buf_is_valid(item.buf) then
		vim.api.nvim_set_current_buf(item.buf)
	end
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

-- <S-j> / <S-k> open the popup (M.peek reads all further keys itself).
function M.cycle()
	M.peek()
end

return M
