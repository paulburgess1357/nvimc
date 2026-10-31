local M = {}

-- One session per launch directory, saved automatically on quit and restored
-- on demand (dashboard `s` / :SessionRestore). Built on :mksession, no plugin.
--
-- Files live in stdpath("state")/sessions/, named after the directory Neovim
-- was STARTED in (a later :cd does not change which session is written):
--   <dir>.vim   the :mksession script
--   <dir>.json  what :mksession can't see: buffer-tab order (utils.buftabs),
--               tab page names (utils.tabs), the visible terminals in each
--               tab (M.term) and the quickfix list
--
-- A diff (diffview) is closed before the save, and after a restore the
-- tabs :mksession could only bring back empty get their dashboard (tidy).

-- No `blank` / `terminal`: nofile plugin windows (aerial, dap-ui, ...) can't
-- be revived, and terminals are respawned through M.term instead.
vim.o.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize"

local dir = vim.fn.stdpath("state") .. "/sessions/"
local base = dir .. vim.fn.getcwd():gsub("[/\\:]", "%%")

-- Terminal provider, registered by utils.terms:
--   { close_all = fun(), snapshot = fun(): table, restore = fun(terms: table) }
M.term = nil

local deleted = false

-- Quickfix: :mksession skips the window (a nofile buffer) and never saves the
-- list itself, so both are recorded here. Only the current list, not the
-- whole stack; location lists are per-window and not covered.
local function qf_snapshot()
	local info = vim.fn.getqflist({ items = 1, title = 1, winid = 1 })
	local open = info.winid ~= 0
	if #info.items == 0 and not open then return nil end
	local items = {}
	for _, it in ipairs(info.items) do
		items[#items + 1] = {
			filename = it.bufnr > 0 and vim.api.nvim_buf_get_name(it.bufnr) or nil,
			lnum = it.lnum,
			col = it.col,
			end_lnum = it.end_lnum,
			end_col = it.end_col,
			vcol = it.vcol,
			type = it.type,
			text = it.text,
		}
	end
	return {
		title = info.title,
		items = items,
		height = open and vim.api.nvim_win_get_height(info.winid) or nil,
		line = open and vim.api.nvim_win_get_cursor(info.winid)[1] or nil,
		focus = open and vim.api.nvim_get_current_win() == info.winid or nil,
	}
end

-- `:copen` always opens full-width at the bottom of the screen, so it lands
-- under the terminal row just as it would have when the list was first opened.
local function qf_restore(qf)
	if type(qf.items) == "table" then
		vim.fn.setqflist({}, " ", { items = qf.items, title = qf.title })
	end
	if qf.height then
		local cur = vim.api.nvim_get_current_win()
		vim.cmd("copen " .. qf.height)
		if qf.line then pcall(vim.api.nvim_win_set_cursor, 0, { qf.line, 0 }) end
		if not qf.focus and vim.api.nvim_win_is_valid(cur) then vim.api.nvim_set_current_win(cur) end
	end
end

-- Diffview's tab (plugin/editor/diffview.lua) is a view of the repository,
-- not a layout of files: :mksession would record its diffview:// buffers
-- and bring the tab back broken. Every diff is closed before a save, which
-- also keeps the terminal snapshot's tab numbers in step with the session's.
local function close_diffs()
	local lib = package.loaded["diffview.lib"]
	if not lib then return end
	for _, view in ipairs(vim.list_slice(lib.views)) do
		view:close()
		lib.dispose_view(view)
	end
end

-- After the session loaded: a diff tab a session saved before close_diffs
-- existed is closed, with its diffview:// buffers. Then the empty windows
-- :mksession leaves behind: a tab whose windows it could not record (a
-- dashboard, or only terminals, which M.term brings back) comes back as
-- one [No Name] window. Beside other windows it is closed; alone in its
-- tab it gets the dashboard, as :NewTab makes it. Tab names are on the
-- tab handles by now, so closing a tab shifts no name.
local function tidy()
	for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
		for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
			if vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win)):match("^diffview://") then
				if #vim.api.nvim_list_tabpages() > 1 then
					vim.cmd(vim.api.nvim_tabpage_get_number(tab) .. "tabclose!")
				end
				break
			end
		end
	end
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_get_name(buf):match("^diffview://") then pcall(vim.api.nvim_buf_delete, buf, { force = true }) end
	end
	local cur = vim.api.nvim_get_current_win()
	for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
		local wins = vim.tbl_filter(function(w) return vim.api.nvim_win_get_config(w).relative == "" end, vim.api.nvim_tabpage_list_wins(tab))
		for _, win in ipairs(wins) do
			local buf = vim.api.nvim_win_get_buf(win)
			local empty = vim.api.nvim_buf_get_name(buf) == ""
				and vim.bo[buf].buftype == ""
				and not vim.bo[buf].modified
				and vim.api.nvim_buf_line_count(buf) == 1
				and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == ""
			if empty then
				if #wins > 1 then
					pcall(vim.api.nvim_win_close, win, false)
				else
					require("utils.tabs").dashboard(win)
				end
			end
		end
	end
	if vim.api.nvim_win_is_valid(cur) then vim.api.nvim_set_current_win(cur) end
end

local function has_files()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.bo[buf].buflisted and vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= "" then
			return true
		end
	end
	return false
end

function M.exists()
	return vim.fn.filereadable(base .. ".vim") == 1
end

function M.save()
	deleted = false
	close_diffs()
	vim.fn.mkdir(dir, "p")
	vim.cmd("mksession! " .. vim.fn.fnameescape(base .. ".vim"))
	local extra = {
		tabs = require("utils.buftabs").names(),
		tabnames = require("utils.tabs").names(),
		terms = M.term and M.term.snapshot() or {},
		qf = qf_snapshot(),
	}
	vim.fn.writefile({ vim.json.encode(extra) }, base .. ".json")
end

function M.restore()
	if not M.exists() then
		vim.notify("No session for " .. vim.fn.getcwd(), vim.log.levels.WARN, { title = "Session" })
		return
	end
	-- Start from a clean slate: the session script's `only` must run from a
	-- plain window, not a terminal, and with no layout hooks pending.
	if M.term then M.term.close_all() end
	if vim.bo.buftype == "terminal" then vim.cmd("new") end
	vim.cmd("silent! only")
	vim.cmd("silent! source " .. vim.fn.fnameescape(base .. ".vim"))
	local ok, extra = pcall(function()
		return vim.json.decode(table.concat(vim.fn.readfile(base .. ".json")))
	end)
	if not ok or type(extra) ~= "table" then return end
	if type(extra.tabs) == "table" then require("utils.buftabs").restore(extra.tabs) end
	if type(extra.tabnames) == "table" then require("utils.tabs").restore(extra.tabnames) end
	if M.term and type(extra.terms) == "table" then M.term.restore(extra.terms) end
	if type(extra.qf) == "table" then qf_restore(extra.qf) end
	tidy()
end

-- Also stops this run from re-saving on quit, so the delete sticks.
function M.delete()
	deleted = true
	vim.fn.delete(base .. ".vim")
	vim.fn.delete(base .. ".json")
end

function M.setup()
	vim.api.nvim_create_autocmd("VimLeavePre", {
		callback = function()
			-- Nothing worth saving (quit from the dashboard, :checkhealth, ...):
			-- keep the previous session rather than overwriting it with nothing.
			if deleted or not has_files() then return end
			-- Launched as git's editor (commit message, rebase todo, ...)
			if vim.fn.argv(0):find("/.git/", 1, true) then return end
			pcall(M.save)
		end,
	})

	vim.api.nvim_create_user_command("SessionSave", M.save, { desc = "Save session for the launch directory" })
	vim.api.nvim_create_user_command("SessionRestore", M.restore, { desc = "Restore session for the launch directory" })
	vim.api.nvim_create_user_command("SessionDelete", M.delete, { desc = "Delete session for the launch directory" })
end

return M
