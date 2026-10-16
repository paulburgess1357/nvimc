local M = {}

-- Buffer tabs without a tabline. This module keeps an ordered list of listed
-- buffers (open order, kept stable as buffers come and go) and the <S-k>/<S-j>
-- peek popup below shows it. The order lives
-- in memory; utils.session saves/restores it. In a terminal window the same
-- keys walk the Term slots instead (utils.terms), from normal mode.

-- Bufnrs in display order. Synced lazily by M.list().
local order = {}

-----------------------------------------------------------
-- Peek popup. There is no tabline (showtabline=0 in options.lua), so
-- <S-j>/<S-k> pop a small float at the top left of the current window
-- listing the tabs in order (the Term slots in a terminal window), the
-- current one on a highlighted line like mini.files. It is modal: j/k (or
-- <S-j>/<S-k>) and gg/G move the highlight, <CR>/<S-CR>/l/L switch to the
-- highlighted entry, <Esc>/q cancel, / and ? search like Vim (then n/N),
-- and every other key is swallowed. Nothing changes until you choose, so
-- browsing terminals does not move focus or open hidden slots. A float,
-- unlike toggling the tabline, does not shift the layout.
-----------------------------------------------------------
local PEEK_NS = vim.api.nvim_create_namespace("buftabs_peek")
local peek_buf, peek_win, preview_win
local peek_items, peek_sel -- entries shown, index of the highlighted one

local function peek_close()
	for _, w in ipairs({ preview_win, peek_win }) do
		if w and vim.api.nvim_win_is_valid(w) then vim.api.nvim_win_close(w, true) end
	end
	peek_win, preview_win, peek_items, peek_sel = nil, nil, nil, nil
end

local function border()
	return (require("config.plugins").settings or {}).border or "single"
end

-- Preview float to the right of the list, showing the highlighted entry's
-- real buffer (syntax and all; a terminal shows its live output). Always on
-- and sized like mini.files' preview: its windows.width_preview wide, as
-- tall as the window allows. `list_width` is the list float's inner width.
local function peek_preview(list_width)
	local item = peek_items[peek_sel]
	local buf = item and item.buf
	if not (buf and vim.api.nvim_buf_is_valid(buf)) then
		if preview_win and vim.api.nvim_win_is_valid(preview_win) then vim.api.nvim_win_close(preview_win, true) end
		preview_win = nil
		return
	end
	local win = vim.api.nvim_get_current_win()
	local col = list_width + 3 -- list border (2) + gap (1)
	local ok, mf = pcall(require, "mini.files")
	local want = ok and mf.config.windows.width_preview or 100
	local width = math.min(want, vim.api.nvim_win_get_width(win) - col - 2)
	local height = vim.api.nvim_win_get_height(win) - 2 -- minus borders
	if width < 10 or height < 3 then return end
	local config = {
		relative = "win",
		win = win,
		anchor = "NW",
		row = 0,
		col = col,
		width = width,
		height = height,
		style = "minimal",
		title = " " .. item.name .. " ",
		title_pos = "left",
		border = border(),
		focusable = false,
		zindex = 60,
	}
	if preview_win and vim.api.nvim_win_is_valid(preview_win) then
		if vim.api.nvim_win_get_buf(preview_win) ~= buf then vim.api.nvim_win_set_buf(preview_win, buf) end
		vim.api.nvim_win_set_config(preview_win, config)
	else
		preview_win = vim.api.nvim_open_win(buf, false, config)
	end
	vim.wo[preview_win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder"
	vim.wo[preview_win].winbar = "" -- utils.terms puts its Term<n> winbar on any window showing the buffer
	vim.wo[preview_win].cursorline = true
	local last = vim.api.nvim_buf_line_count(buf)
	if item.slot then
		-- Terminal: history filling the preview, latest output at the bottom.
		-- The buffer ends in blank padding rows, so find the last real line.
		local line = last
		while line > 1 and vim.api.nvim_buf_get_lines(buf, line - 1, line, false)[1]:match("^%s*$") do
			line = line - 1
		end
		vim.api.nvim_win_set_cursor(preview_win, { line, 0 })
		vim.api.nvim_win_call(preview_win, function() vim.cmd("normal! zb") end)
	else
		-- File: centered on its last cursor position.
		local line = math.max(1, math.min(vim.api.nvim_buf_get_mark(buf, '"')[1], last))
		vim.api.nvim_win_set_cursor(preview_win, { line, 0 })
		vim.api.nvim_win_call(preview_win, function() vim.cmd("normal! zz") end)
	end
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
		out[i] = { slot = slot.n, buf = slot.buf, name = slot.label, icon = "", current = slot.buf == cur }
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
		item.name_col = #prefix -- byte offset of the name, for search highlights
		width = math.max(width, vim.fn.strdisplaywidth(line))
	end
	return lines, hls, width
end

-- Vim-style search over the entries. / and ? read a pattern (plain text,
-- 'ignorecase' and 'smartcase' honored); the highlight follows the first
-- match as you type, like 'incsearch'. <CR> keeps it there, <Esc> goes back
-- to where you were, and n/N then step through the matches, which stay
-- highlighted (Search, CurSearch on the highlighted entry) like 'hlsearch'.
local peek_search -- { text, dir (1 forward, -1 backward), typing, from } or nil
local peek_list_width

-- Byte span of the pattern in the entry's name, or nil.
local function match_at(item, pat)
	if pat == "" then return nil end
	local name = item.name
	if vim.o.ignorecase and not (vim.o.smartcase and pat:match("%u")) then
		name, pat = name:lower(), pat:lower()
	end
	return name:find(pat, 1, true)
end

-- Index of the next matching entry after `from` in direction `dir`,
-- wrapping around; `from` itself is tried last. nil when nothing matches.
local function next_match(from, dir)
	local n = #peek_items
	for step = 1, n do
		local i = (from - 1 + step * dir) % n + 1
		if match_at(peek_items[i], peek_search.text) then return i end
	end
end

-- Draw (or redraw) the popup: entries, search highlights, title, preview.
local function peek_render()
	local lines, hls, width = peek_lines(peek_items)
	-- Titled like mini.files (FloatTitle, left, padded); never narrower than
	-- the title, which is wider than a short list of Term<n> entries. A
	-- search shows its pattern, with a _ while it is still being typed.
	local title = (in_terminal() and " Terminals" or " Buffers") .. " "
	if peek_search then
		title = title .. (peek_search.dir == 1 and "/" or "?") .. peek_search.text .. (peek_search.typing and "_" or "") .. " "
	end
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
	if peek_search then
		for i, item in ipairs(peek_items) do
			local s, e = match_at(item, peek_search.text)
			if s then
				vim.api.nvim_buf_set_extmark(peek_buf, PEEK_NS, i - 1, item.name_col + s - 1, {
					end_col = item.name_col + e,
					hl_group = i == peek_sel and "CurSearch" or "Search",
				})
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
		border = border(),
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
	peek_list_width = width
	peek_preview(width)
end

-- Move the highlight (wrapping) and redraw.
local function peek_select(i)
	peek_sel = (i - 1) % #peek_items + 1
	peek_render()
end

-- Re-run the search being typed from where it started ('incsearch'): the
-- highlight goes to the first match, or back to the start when none.
local function peek_incsearch()
	peek_select(next_match(peek_search.from, peek_search.dir) or peek_search.from)
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
	peek_items, peek_search, peek_sel = items, nil, 1
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
		local enter = name == "<CR>" or name == "<S-CR>" or name == "<NL>"
		if peek_search and peek_search.typing then
			-- Typing a pattern: as in Vim's / prompt, <CR> keeps the match,
			-- <Esc> abandons the search, <BS> past an empty pattern too.
			if enter then
				peek_search.typing = false
				if peek_search.text == "" then peek_search = nil end
				peek_render()
			elseif name == "<Esc>" then
				local from = peek_search.from
				peek_search = nil
				peek_select(from)
			elseif name == "<BS>" or name == "<C-H>" or name == "<Del>" then -- as Vim's prompt takes them
				if peek_search.text == "" then
					local from = peek_search.from
					peek_search = nil
					peek_select(from)
				else
					peek_search.text = peek_search.text:sub(1, -2)
					peek_incsearch()
				end
			elseif #k == 1 and k:match("[%g ]") then
				peek_search.text = peek_search.text .. k
				peek_incsearch()
			end
		elseif k == "j" or k == "J" then -- J/K: Shift still held from <S-j>/<S-k>
			peek_select(peek_sel + 1)
		elseif k == "k" or k == "K" then
			peek_select(peek_sel - 1)
		elseif k == "g" then
			local ok2, k2 = pcall(vim.fn.getcharstr)
			if ok2 and k2 == "g" then peek_select(1) end
		elseif k == "G" then
			peek_select(#peek_items)
		elseif k == "/" or k == "?" then
			peek_search = { text = "", dir = k == "/" and 1 or -1, typing = true, from = peek_sel }
			peek_render()
		elseif (k == "n" or k == "N") and peek_search then
			local i = next_match(peek_sel, k == "n" and peek_search.dir or -peek_search.dir)
			if i then peek_select(i) end
		elseif enter or k == "l" or k == "L" then -- L: still holding Shift
			chosen = peek_items[peek_sel]
			break
		elseif name == "<Esc>" or k == "q" then
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
		-- Switching with the API fires no CursorMoved, so vim-illuminate
		-- would leave the highlights from the last visit until the next
		-- key. Drop them and refresh once for the cursor as it is now.
		local ok, hl = pcall(require, "illuminate.highlight")
		if ok then
			hl.buf_clear_references(item.buf)
			require("illuminate.engine").refresh_references(item.buf, vim.api.nvim_get_current_win())
		end
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

return M
