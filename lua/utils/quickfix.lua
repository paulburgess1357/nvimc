-- Quickfix and location list entries drawn like the fzf-lua pickers that
-- feed them, instead of Vim's "file|12 col 3| text":
--
--    <devicon> lua/utils/terms.lua   412:3   local function setup_term_buf(n, buf)
--    <devicon> lua/config/keymaps.lua 20:1   <diag icon> Undefined variable `x`
--
-- Columns are aligned across the list: the path (relative to cwd, the
-- directory in grey and the file in the normal color, cut from the left
-- with an ellipsis past MAX_PATH columns), then line:column in the picker's
-- line / column colors, then the text with its leading indent dropped. An
-- entry with a diagnostic type (E/W/I/N: vim.diagnostic.setqflist, a
-- picker's diagnostics sent with <C-q>) gets the level's glyph (utils.ui)
-- in front of its text, and an entry with no file (a :make message) shows
-- its text alone. The current entry's slab (QuickFixLine) and the column
-- colors (Quickfix*) are set in config/colorscheme.lua.
--
-- 'quickfixtextfunc' only produces text, so the colors are drawn from a
-- decoration provider: M.text records a highlight span per column as it
-- lays each line out, keyed by the list's buffer and line, and the provider
-- paints them whenever a quickfix window is redrawn. That covers every way
-- the buffer changes (a new list, :caddexpr appending, :colder/:cnewer).
-- Loaded from config/options.lua.

local M = {}

local ui = require("utils.ui")

local NS = vim.api.nvim_create_namespace("quickfix_style")
local MAX_PATH = 40 -- columns for the path before its directory is cut from the left
local GAP = "  " -- between columns

-- qf buffer -> { [line] = { { start_col, end_col, hl_group }, ... } }
local spans = {}

-- Diagnostic type letter -> { glyph, highlight }. vim.diagnostic uses E/W/I/N.
local TYPES = {
	E = { ui.diagnostics.error, "DiagnosticError" },
	W = { ui.diagnostics.warn, "DiagnosticWarn" },
	I = { ui.diagnostics.info, "DiagnosticInfo" },
	N = { ui.diagnostics.hint, "DiagnosticHint" },
	H = { ui.diagnostics.hint, "DiagnosticHint" },
}

local function width(s)
	return vim.fn.strdisplaywidth(s)
end

-- Pad `s` on the right to `w` display columns.
local function rpad(s, w)
	return s .. string.rep(" ", math.max(0, w - width(s)))
end

-- The path of an item split in { dir, tail }: relative to cwd (or ~), the
-- directory cut from the left to keep the whole within MAX_PATH where the
-- file name alone allows it. "" / "" for an item without a file.
local function split_path(bufnr)
	if not bufnr or bufnr <= 0 then return "", "" end
	local name = vim.api.nvim_buf_get_name(bufnr)
	if name == "" then return "", "" end
	name = vim.fn.fnamemodify(name, ":~:.")
	local tail = vim.fn.fnamemodify(name, ":t")
	local dir = name:sub(1, #name - #tail)
	local room = MAX_PATH - width(tail)
	if width(dir) > room then
		if room < 3 then
			dir = ""
		else
			while width(dir) > room - 1 do
				dir = vim.fn.strcharpart(dir, 1)
			end
			dir = "…" .. dir
		end
	end
	return dir, tail
end

-- Line builder: appends pieces, recording a highlight span for each that
-- has a group, and returns the line and its spans.
local function line_builder()
	local parts, hls, col = {}, {}, 0
	local b = {}
	function b.add(text, hl)
		if text == "" then return end
		parts[#parts + 1] = text
		if hl then hls[#hls + 1] = { col, col + #text, hl } end
		col = col + #text
	end
	function b.done()
		return table.concat(parts), hls
	end
	return b
end

-- 'quickfixtextfunc'. Vim calls it with the range of items to render
-- (start_idx..end_idx, all of them for a fresh list) and expects one string
-- per item. Column widths are measured over the whole list, not the range,
-- so lines appended later still line up with the earlier ones.
function _G.quickfix_text(info)
	local what = { id = info.id, items = 1, qfbufnr = 1 }
	local list = info.quickfix == 1 and vim.fn.getqflist(what) or vim.fn.getloclist(info.winid, what)
	local items = list.items or {}
	local ok_dev, devicons = pcall(require, "nvim-web-devicons")

	-- Layout pass: every item's columns and the widths they need.
	local rows, path_w, pos_w = {}, 0, 0
	for i, it in ipairs(items) do
		local dir, tail = split_path(it.bufnr)
		local pos = ""
		if tail ~= "" and (it.lnum or 0) > 0 then
			pos = tostring(it.lnum) .. ((it.col or 0) > 0 and (":" .. it.col) or "")
		end
		rows[i] = { dir = dir, tail = tail, pos = pos }
		path_w = math.max(path_w, width(dir) + width(tail))
		pos_w = math.max(pos_w, width(pos))
	end

	-- A fresh list (rendered from its first item) drops the old spans; an
	-- append keeps them and adds its own.
	local buf = list.qfbufnr
	local buf_spans
	if buf and buf > 0 then
		if info.start_idx == 1 or not spans[buf] then spans[buf] = {} end
		buf_spans = spans[buf]
	end

	local out = {}
	for i = info.start_idx, info.end_idx do
		local it, row = items[i], rows[i]
		local b = line_builder()
		if it and row then
			local text = (it.text or ""):gsub("^%s+", "")
			local has_file = row.tail ~= ""
			-- Icon column: the file's devicon, or a blank of the same width.
			local icon, icon_hl = nil, nil
			if has_file and ok_dev then
				icon, icon_hl = devicons.get_icon(row.tail, vim.fn.fnamemodify(row.tail, ":e"), { default = true })
			end
			b.add(" ")
			b.add(icon or " ", icon_hl)
			b.add(" ")
			if has_file then
				b.add(row.dir, "QuickfixDir")
				b.add(row.tail, "QuickfixFile")
				b.add(string.rep(" ", path_w - width(row.dir) - width(row.tail)))
				b.add(GAP)
				-- "412:3" as three pieces so the line and column take their own colors.
				local lnum, col = row.pos:match("^(%d+):?(%d*)$")
				if lnum then
					b.add(lnum, "QuickfixLineNr")
					if col ~= "" then
						b.add(":", "QuickfixSep")
						b.add(col, "QuickfixColNr")
					end
				end
				b.add(string.rep(" ", pos_w - width(row.pos)))
				b.add(GAP)
			elseif path_w + pos_w > 0 then
				-- No file: keep the text in the text column of the other rows.
				b.add(string.rep(" ", path_w + #GAP + pos_w + #GAP))
			end
			local t = TYPES[(it.type or ""):upper()]
			if t and text ~= "" then
				b.add(t[1], t[2])
				b.add(" ")
			end
			b.add(text)
		end
		local line, hls = b.done()
		out[#out + 1] = line
		if buf_spans then buf_spans[i] = hls end
	end
	return out
end

-- Fallback colors for a theme that defines none (config/colorscheme.lua
-- sets onedark's). `default` links never override an existing definition.
local function ensure_highlights()
	for group, link in pairs({
		QuickfixDir = "Comment",
		QuickfixFile = "Normal",
		QuickfixLineNr = "LineNr",
		QuickfixColNr = "Number",
		QuickfixSep = "Comment",
	}) do
		vim.api.nvim_set_hl(0, group, { link = link, default = true })
	end
end

function M.setup()
	vim.o.quickfixtextfunc = "v:lua.quickfix_text"

	vim.api.nvim_set_decoration_provider(NS, {
		on_win = function(_, _, buf)
			return spans[buf] ~= nil
		end,
		on_line = function(_, _, buf, row)
			local hls = spans[buf] and spans[buf][row + 1]
			if not hls then return end
			for _, s in ipairs(hls) do
				-- pcall: a span past the end of a line the list has since replaced.
				pcall(vim.api.nvim_buf_set_extmark, buf, NS, row, s[1], {
					end_col = s[2],
					hl_group = s[3],
					ephemeral = true,
				})
			end
		end,
	})

	-- 'filetype' is re-set to qf every time a list buffer is filled.
	vim.api.nvim_create_autocmd("FileType", { pattern = "qf", callback = ensure_highlights })
	vim.api.nvim_create_autocmd("BufWipeout", {
		callback = function(ev)
			spans[ev.buf] = nil
		end,
	})
end

return M
