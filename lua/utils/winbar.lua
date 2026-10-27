-- Winbars that name their window, laid out like the Term<n> titles in
-- utils.terms (" <icon> <name> ●") and colored like the buffer popup: with
-- several splits open, every pane says what it shows, the same way every
-- terminal says which slot it is.
--
--   file windows   " <devicon> <filename> ●"  (● when modified)
--   side windows   " <icon> <name>"           aerial, quickfix, help, the
--                                             diffview and dap-ui panels
--                                             (utils.ui.windows, by filetype)
--   terminals      " <devicon> Term<n> (name) · title"
--                                             set by utils.terms, drawn by
--                                             M.render here, so the three
--                                             cannot drift apart
--
-- Pickers, the dashboard, floats, etc. get none.
--
-- A side window and a terminal also get the same gutter: none (M.plain_gutter),
-- where a file window keeps its line numbers and sign column.

local M = {}

local ui = require("utils.ui")

-- " <icon> <name>[ ●][<detail>]" with the active window in the mode color
-- (LualineBufActive, set in config/colorscheme.lua) and its icon in
-- `icon_hl`; an inactive window in WinBarNC grey end to end, icon included.
-- `detail` (the terminal's " · title") follows in the plain WinBar color and
-- is what gets truncated when the window is narrow.
function M.render(icon, icon_hl, name, modified, detail)
	local active = tonumber(vim.g.actual_curwin) == vim.api.nvim_get_current_win()
	local parts = { " " }
	if icon and icon ~= "" then
		parts[#parts + 1] = (active and icon_hl and ("%#" .. icon_hl .. "#") or "%#WinBarNC#") .. icon .. "%* "
	end
	parts[#parts + 1] = (active and "%#LualineBufActive#" or "%#WinBarNC#") .. name:gsub("%%", "%%%%") .. "%*"
	if modified then parts[#parts + 1] = " ●" end
	if detail and detail ~= "" then parts[#parts + 1] = "%<" .. detail:gsub("%%", "%%%%") end
	return table.concat(parts)
end
local render = M.render

function _G.file_winbar()
	local name = vim.fn.expand("%:t")
	if name == "" then return "" end
	local icon, hl = "", nil
	local ok, devicons = pcall(require, "nvim-web-devicons")
	if ok then
		icon, hl = devicons.get_icon(name, vim.fn.expand("%:e"), { default = true })
	end
	return render(icon, hl, name, vim.bo.modified)
end

function _G.named_winbar()
	local spec = ui.windows[vim.bo.filetype]
	if not spec then return "" end
	local name = type(spec.name) == "function" and spec.name() or spec.name
	return render(spec.icon, spec.hl, name, false)
end

-- The window options of a pane that lists or shows things rather than edits
-- a file: no line numbers, sign column, fold column or listchars. Applied
-- with the named winbar, and by utils.terms to its terminals.
function M.plain_gutter(win)
	local wo = vim.wo[win][0]
	wo.number, wo.relativenumber = false, false
	wo.signcolumn, wo.foldcolumn = "no", "0"
	wo.list = false
end

local FILE_WINBAR = "%{%v:lua.file_winbar()%}"
local NAMED_WINBAR = "%{%v:lua.named_winbar()%}"

local function wants_file_winbar(win)
	local buf = vim.api.nvim_win_get_buf(win)
	return vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= ""
end

local function wants_named_winbar(win)
	return ui.windows[vim.bo[vim.api.nvim_win_get_buf(win)].filetype] ~= nil
end

-- Give `win` the winbar its buffer calls for, or take ours away when the
-- buffer no longer does (a terminal or a picker landing in the window).
local function apply(win)
	-- Floats get none, except the snacks zoom float (snacks_main), which
	-- stands in for the window it covers and keeps its title.
	if vim.api.nvim_win_get_config(win).relative ~= "" and not vim.w[win].snacks_main then return end
	if wants_file_winbar(win) then
		vim.wo[win].winbar = FILE_WINBAR
	elseif wants_named_winbar(win) then
		vim.wo[win].winbar = NAMED_WINBAR
		M.plain_gutter(win)
	elseif vim.wo[win].winbar == FILE_WINBAR or vim.wo[win].winbar == NAMED_WINBAR then
		vim.wo[win].winbar = ""
	end
end

function M.setup()
	local group = vim.api.nvim_create_augroup("file_winbar", { clear = true })
	vim.api.nvim_create_autocmd({ "BufWinEnter", "BufFilePost", "TermOpen" }, {
		group = group,
		callback = function() apply(vim.api.nvim_get_current_win()) end,
	})
	-- Side windows are told apart by filetype, which plugins set after the
	-- buffer is already in its window.
	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		pattern = vim.tbl_keys(ui.windows),
		callback = function(ev)
			for _, win in ipairs(vim.fn.win_findbuf(ev.buf)) do apply(win) end
		end,
	})
end

return M
