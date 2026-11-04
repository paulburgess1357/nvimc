local M = {}

-- One session per launch directory, saved automatically on quit and restored
-- on demand (dashboard `s` / :SessionRestore). Built on :mksession, no plugin.
--
-- Files live in stdpath("state")/sessions/, named after the directory Neovim
-- was STARTED in (a later :cd does not change which session is written;
-- M.switch, behind the :Sessions picker, does):
--   <dir>.vim   the :mksession script
--   <dir>.json  what :mksession can't see: the directory itself (for
--               M.list), the session's name (:Session <name>), buffer-tab
--               order (utils.buftabs), tab page slots and names
--               (utils.tabs), the visible terminals in each tab (M.term),
--               the quickfix list, the current window of each tab (which
--               :mksession keeps for the current tab only) and the window
--               sizes of each tab (which :mksession drops for a tab holding
--               a window it skips, see layouts_snapshot)
--
-- A diff (diffview) is closed before the save, and after a restore the
-- tabs :mksession could only bring back empty get their dashboard (tidy).
-- The terminals come back after the session script has set every window's
-- cursor and placed them, so the file windows they split shrink
-- afterwards: with 'splitkeep' "screen" the text stays and a cursor that
-- falls out of the window is moved up instead. Each window's view is
-- therefore recorded after the script and put back once the layout is
-- final (M.restore).

-- No `blank` / `terminal`: nofile plugin windows (aerial, dap-ui, ...) can't
-- be revived, and terminals are respawned through M.term instead.
vim.o.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize"

local dir = vim.fn.stdpath("state") .. "/sessions/"
-- The directory the session is for, and its files' path without extension.
local root = vim.fs.normalize(vim.fn.getcwd())
local function base_for(path)
	return dir .. path:gsub("[/\\:]", "%%")
end
local base = base_for(root)

-- Terminal provider, registered by utils.terms:
--   { close_all = fun(), snapshot = fun(): table, restore = fun(terms: table),
--     slot = fun(win): integer?, repair = fun(), kill_idle = fun() }
M.term = nil

local deleted = false

-- The session's name (:Session <name>), a label like a tab's or a terminal's:
-- the directory stays what identifies the session. Kept here and written
-- with the .json on save, as tab names are. Read from the .json on first
-- use, not at startup, so a run that never restores (open a file, quit)
-- still keeps the name it had.
local name, name_loaded = nil, false

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
-- The right columns (Term 7-10) are cut short by that too; utils.terms
-- repairs it on the FileType event, but scheduled, so it is also done here,
-- now, for layouts_restore to find the layout the sizes were saved in.
local function qf_restore(qf)
	if type(qf.items) == "table" then
		vim.fn.setqflist({}, " ", { items = qf.items, title = qf.title })
	end
	if qf.height then
		local cur = vim.api.nvim_get_current_win()
		vim.cmd("copen " .. qf.height)
		if M.term and M.term.repair then pcall(M.term.repair) end
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
-- tab it gets the dashboard, as `:Tab <n>` makes it. Tab names are on the
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

-- The windows of a tab that :mksession writes, in its order (the order
-- nvim_tabpage_list_wins gives, too): file windows and help windows. Not
-- floats, nor terminals, nofile windows or an unnamed buffer's window,
-- which 'sessionoptions' leaves out.
local function session_wins(tab)
	return vim.tbl_filter(function(win)
		if vim.api.nvim_win_get_config(win).relative ~= "" then return false end
		local buf = vim.api.nvim_win_get_buf(win)
		local bt = vim.bo[buf].buftype
		return bt == "help" or (bt == "" and vim.api.nvim_buf_get_name(buf) ~= "")
	end, vim.api.nvim_tabpage_list_wins(tab))
end

-- Current window of each tab, { ["2"] = 3 }: its index among the tab's
-- session windows (string keys, as utils.tabs.names). :mksession restores
-- it for the tab that is current at the save and leaves every other tab on
-- its first window. A tab whose current window is one :mksession skips (a
-- terminal, the dashboard) has no entry; M.term puts the cursor back in a
-- focused terminal itself.
local function curwins_snapshot()
	local out = {}
	for nr, tab in ipairs(vim.api.nvim_list_tabpages()) do
		local cur = vim.api.nvim_tabpage_get_win(tab)
		for i, win in ipairs(session_wins(tab)) do
			if win == cur then out[tostring(nr)] = i end
		end
	end
	return out
end

-- Right after the session script, when each tab holds exactly its session
-- windows. Only the tab's own current window is set; the current tab and
-- window of the whole session are left as the script set them.
local function curwins_restore(curwins)
	local tabs = vim.api.nvim_list_tabpages()
	for nr, i in pairs(curwins) do
		local tab = tabs[tonumber(nr)]
		local win = tab and session_wins(tab)[i]
		if win then pcall(vim.api.nvim_tabpage_set_win, tab, win) end
	end
end

-- Window sizes. 'sessionoptions' has "winsize", but :mksession writes a
-- tab's resize commands only when it recorded every window of the tab; a
-- tab with a window it skips (a terminal, the dashboard, aerial...) gets
-- `wincmd =` instead and comes back with equal splits. So each tab's
-- layout tree (utils.winscale) is saved too, with every window under a
-- name the next run gives it again: file windows by their index among the
-- session windows, terminals by slot, the quickfix window. Once the
-- terminals and the quickfix list are back, each frame whose windows are
-- all there again gets its sizes back (its shares, on a screen of another
-- size). A window nothing brings back is named by its handle, which
-- matches nothing: the frame holding it is left as :mksession made it.
local function ident_for(tab)
	local names = {}
	for i, win in ipairs(session_wins(tab)) do names[win] = "f" .. i end
	return function(win)
		if names[win] then return names[win] end
		local slot = M.term and M.term.slot and M.term.slot(win)
		if slot then return "t" .. slot end
		if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "quickfix" then return "qf" end
		return "x" .. win
	end
end

-- { ["1"] = tree, ... } by tab number.
local function layouts_snapshot()
	local winscale = require("utils.winscale")
	local out = {}
	for nr, tab in ipairs(vim.api.nvim_list_tabpages()) do
		out[tostring(nr)] = winscale.record(nr, ident_for(tab))
	end
	return out
end

-- Once the layout is final (terminals, quickfix and tidy done): winscale
-- works on the current tab, so each tab is entered in turn.
local function layouts_restore(layouts)
	local winscale = require("utils.winscale")
	local cur = vim.api.nvim_get_current_tabpage()
	local tabs = vim.api.nvim_list_tabpages()
	for nr, tree in pairs(layouts) do
		local tab = tabs[tonumber(nr)]
		if tab and type(tree) == "table" then
			vim.api.nvim_set_current_tabpage(tab)
			pcall(winscale.restore, tree, ident_for(tab))
		end
	end
	if vim.api.nvim_tabpage_is_valid(cur) then vim.api.nvim_set_current_tabpage(cur) end
end

-- Every file window's view as the session script set it, by window
-- handle: cursor, top line and height.
local function views_snapshot()
	local out = {}
	for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
		for _, win in ipairs(session_wins(tab)) do
			out[win] = {
				buf = vim.api.nvim_win_get_buf(win),
				cursor = vim.api.nvim_win_get_cursor(win),
				top = vim.api.nvim_win_call(win, function() return vim.fn.line("w0") end),
				height = vim.api.nvim_win_get_height(win),
			}
		end
	end
	return out
end

-- Once the layout is final: the cursor back on its line, at the same
-- share of the window's height it had (the script computed the top line
-- for the window's height then; a window the terminals shrank keeps that
-- top line and Neovim moves the cursor up to fit). Setting the top line
-- with the cursor lets Neovim scroll, not move the cursor, if 'scrolloff'
-- still needs room.
local function views_restore(saved)
	for win, v in pairs(saved) do
		if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == v.buf then
			local height = vim.api.nvim_win_get_height(win)
			local cursor = vim.api.nvim_win_get_cursor(win)
			if height ~= v.height or cursor[1] ~= v.cursor[1] or cursor[2] ~= v.cursor[2] then
				local row = v.cursor[1] - v.top
				if v.height > 0 and height ~= v.height then row = math.floor(row * height / v.height + 0.5) end
				vim.api.nvim_win_call(win, function()
					vim.fn.winrestview({
						lnum = v.cursor[1],
						col = v.cursor[2],
						curswant = v.cursor[2],
						topline = math.max(1, v.cursor[1] - row),
					})
				end)
			end
		end
	end
end

-- The .json of a session, or nil when it is missing or unreadable.
local function read_extra(b)
	local ok, extra = pcall(function()
		return vim.json.decode(table.concat(vim.fn.readfile(b .. ".json")))
	end)
	return (ok and type(extra) == "table") and extra or nil
end

-- The current session's name, nil when it has none.
function M.name()
	if not name_loaded then
		local extra = read_extra(base)
		name = extra and type(extra.name) == "string" and extra.name ~= "" and extra.name or nil
		name_loaded = true
	end
	return name
end

-- Re-assigning 'titlestring' makes Neovim redraw the terminal title now;
-- a name change is no event it watches.
local function refresh_title()
	if vim.o.title then vim.o.titlestring = vim.o.titlestring end
end

function M.set_name(new)
	name = (new and new ~= "") and new or nil
	name_loaded = true
	refresh_title()
end

-- The terminal title (config/options.lua 'titlestring'): the working
-- directory, with ~ for home, and the session's name after it,
-- "~/proj (refactor auth)". Evaluated on every title redraw; the name is
-- read from disk once (M.name), about 25 us.
function M.title()
	local n = M.name()
	return vim.fn.fnamemodify(vim.fn.getcwd(), ":~") .. (n and (" (" .. n .. ")") or "")
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
		cwd = root,
		name = M.name(),
		tabs = require("utils.buftabs").names(),
		tabnames = require("utils.tabs").names(),
		tabslots = require("utils.tabs").slots(),
		terms = M.term and M.term.snapshot() or {},
		qf = qf_snapshot(),
		curwins = curwins_snapshot(),
		layouts = layouts_snapshot(),
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
	local views = views_snapshot()
	local extra = read_extra(base)
	if not extra then return end
	M.set_name(type(extra.name) == "string" and extra.name or nil)
	if type(extra.curwins) == "table" then curwins_restore(extra.curwins) end
	if type(extra.tabs) == "table" then require("utils.buftabs").restore(extra.tabs) end
	require("utils.tabs").restore(
		type(extra.tabnames) == "table" and extra.tabnames or {},
		type(extra.tabslots) == "table" and extra.tabslots or {}
	)
	if M.term and type(extra.terms) == "table" then M.term.restore(extra.terms) end
	if type(extra.qf) == "table" then qf_restore(extra.qf) end
	tidy()
	if type(extra.layouts) == "table" then layouts_restore(extra.layouts) end
	views_restore(views)
end

-- Directories whose sessions :Sessions leaves out: scratch places, not
-- projects (a session is still written there and `s` still restores it):
-- the temp directory and Neovim's cache, with its parent when that is the
-- XDG ~/.cache (other programs' caches too, not all of AppData on Windows).
local function hidden()
	local out = { vim.uv.os_tmpdir(), vim.fn.stdpath("cache") }
	local parent = vim.fs.dirname(vim.fn.stdpath("cache"))
	if vim.fs.basename(parent) == ".cache" then out[#out + 1] = parent end
	return out
end

local function is_hidden(path)
	for _, dir in ipairs(hidden()) do
		if dir and vim.fs.relpath(dir, path) then return true end
	end
	return false
end

-- Every saved session, most recently saved first, for the :Sessions picker
-- (plugin/editor/fzf.lua). Each: { path, name (:Session <name>; the current
-- session's as it is now, not as last saved), current (this run's session),
-- saved (epoch seconds), tabs (count), tabnames ({ ["2"] = "build" }),
-- tabslots ({ ["2"] = 4 }, by position; missing in older sessions),
-- terms ({ { n, tab, name }, ...}) and files (the buffer-tab order,
-- absolute) }. The directory comes from
-- the .json; a file from before it was recorded there is named back from
-- the file name (every `%` was a `/`). Sessions of directories that are
-- gone, or hidden, are left out.
function M.list()
	local out = {}
	for _, vimfile in ipairs(vim.fn.glob(dir .. "*.vim", false, true)) do
		local b = vimfile:sub(1, -5)
		local extra = read_extra(b) or {}
		local path = type(extra.cwd) == "string" and extra.cwd or (vim.fn.fnamemodify(b, ":t"):gsub("%%", "/"))
		path = vim.fs.normalize(path)
		if vim.fn.isdirectory(path) == 1 and not is_hidden(path) then
			local tabs = 0
			if type(extra.layouts) == "table" then
				tabs = #vim.tbl_keys(extra.layouts)
			else
				for _, line in ipairs(vim.fn.readfile(vimfile)) do
					if line:match("^tabnew") then tabs = tabs + 1 end
				end
				tabs = tabs + 1
			end
			local terms = {}
			for _, t in ipairs(type(extra.terms) == "table" and extra.terms or {}) do
				if type(t.n) == "number" then
					terms[#terms + 1] = { n = t.n, tab = type(t.tab) == "number" and t.tab or 1, name = t.name }
				end
			end
			local stat = vim.uv.fs_stat(vimfile)
			local current = b == base
			local name_now
			if current then
				name_now = M.name()
			elseif type(extra.name) == "string" and extra.name ~= "" then
				name_now = extra.name
			end
			out[#out + 1] = {
				path = path,
				name = name_now,
				current = current,
				saved = stat and stat.mtime.sec or 0,
				tabs = tabs,
				tabnames = type(extra.tabnames) == "table" and extra.tabnames or {},
				tabslots = type(extra.tabslots) == "table" and extra.tabslots or {},
				terms = terms,
				files = type(extra.tabs) == "table" and extra.tabs or {},
			}
		end
	end
	table.sort(out, function(a, b) return a.saved > b.saved end)
	return out
end

-- Lines describing an M.list() entry, for the picker's preview: when it
-- was saved, each tab with its name and terminals, then the files.
function M.describe(s)
	local lines = { "Saved " .. os.date("%Y-%m-%d %H:%M", s.saved), "" }
	local by_tab = {}
	for _, t in ipairs(s.terms) do
		by_tab[t.tab] = by_tab[t.tab] or {}
		table.insert(by_tab[t.tab], "Term " .. t.n .. (t.name and (" (" .. t.name .. ")") or ""))
	end
	for nr = 1, s.tabs do
		local name = s.tabnames[tostring(nr)]
		local label = "Tab " .. (s.tabslots[tostring(nr)] or nr) .. (name and (" (" .. name .. ")") or "")
		local terms = by_tab[nr] and (" " .. require("utils.ui").sep .. " " .. table.concat(by_tab[nr], ", ")) or ""
		lines[#lines + 1] = label .. terms
	end
	if #s.files > 0 then
		lines[#lines + 1] = ""
		lines[#lines + 1] = "Files"
		for _, f in ipairs(s.files) do
			local rel = vim.fs.relpath(s.path, f) or vim.fn.fnamemodify(f, ":~")
			lines[#lines + 1] = "  " .. rel
		end
	end
	return lines
end

-- Language servers left with no buffer once the old session's buffers are
-- gone (the new session's servers have their own roots). Stopping them is
-- what Neovim would do had the buffers been closed one by one.
local function stop_idle_lsp()
	for _, client in ipairs(vim.lsp.get_clients()) do
		if next(client.attached_buffers) == nil then client:stop() end
	end
end

local function notify(msg, level)
	vim.notify(msg, level or vim.log.levels.WARN, { title = "Session" })
end

-- Make `path`'s session the current one and restore it (:Sessions):
--
--   1. Refused with a modified buffer (it would be carried over and saved
--      with the other session on quit; :wa or :bd! first) or while a
--      debug session runs.
--   2. The current session is saved, when it holds files and was not
--      deleted; a save that fails leaves everything as it is.
--   3. Teardown: diffs closed, terminal windows closed and, when moving to
--      another directory, idle shells dropped (M.term.kill_idle: a shell
--      running something is kept, as a file buffer would be), every tab
--      but one closed, that tab's windows closed to one, every file buffer
--      dropped, the quickfix stack freed.
--   4. Neovim moves to `path`, the quit-save goes there from now on, and
--      the session is restored as `s` does. Language servers left without
--      a buffer are stopped once the new session's buffers have attached.
--
-- The current directory again saves and reloads it.
function M.switch(path)
	path = vim.fs.normalize(vim.fn.fnamemodify(path, ":p")):gsub("/+$", "")
	local b = base_for(path)
	if vim.fn.filereadable(b .. ".vim") == 0 then return notify("No session for " .. path) end
	local modified = {}
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.bo[buf].buflisted and vim.bo[buf].modified then
			local name = vim.api.nvim_buf_get_name(buf)
			modified[#modified + 1] = name ~= "" and vim.fn.fnamemodify(name, ":t") or "[No Name]"
		end
	end
	if #modified > 0 then
		return notify(("Not switching: %d modified (%s). :wa or :bd! first"):format(#modified, table.concat(modified, ", ")))
	end
	if package.loaded["dap"] and require("dap").session() then
		return notify("Not switching: a debug session is running. Terminate it first")
	end
	if not deleted and has_files() then
		local ok, err = pcall(M.save)
		if not ok then return notify("Not switching: the session could not be saved: " .. tostring(err), vim.log.levels.ERROR) end
	end
	local moving = b ~= base
	close_diffs()
	if M.term then
		M.term.close_all()
		if moving and M.term.kill_idle then M.term.kill_idle() end
	end
	vim.cmd("silent! tabonly")
	vim.cmd("silent! only")
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.bo[buf].buflisted and vim.bo[buf].buftype == "" then pcall(vim.api.nvim_buf_delete, buf, {}) end
	end
	vim.fn.setqflist({}, "f")
	vim.cmd.cd(vim.fn.fnameescape(path))
	root, base, deleted = path, b, false
	name, name_loaded = nil, false
	M.restore()
	refresh_title()
	if moving then vim.defer_fn(stop_idle_lsp, 500) end
end

-- Also stops this run from re-saving on quit, so the delete sticks.
function M.delete()
	deleted = true
	M.set_name(nil)
	vim.fn.delete(base .. ".vim")
	vim.fn.delete(base .. ".json")
end

function M.setup()
	vim.api.nvim_create_autocmd("VimLeavePre", {
		callback = function()
			-- Nothing worth saving (quit from the dashboard, :checkhealth, ...):
			-- keep the previous session rather than overwriting it with nothing.
			if deleted or not has_files() then return end
			-- Launched as git's editor (commit message, rebase todo, ...). Git
			-- gives the path relative to the repository, ".git/COMMIT_EDITMSG",
			-- so it is made absolute before looking for the directory.
			if vim.fn.fnamemodify(vim.fn.argv(0), ":p"):find("/.git/", 1, true) then return end
			pcall(M.save)
		end,
	})

	vim.api.nvim_create_user_command("SessionSave", M.save, { desc = "Save session for the launch directory" })
	vim.api.nvim_create_user_command("SessionRestore", M.restore, { desc = "Restore session for the launch directory" })
	vim.api.nvim_create_user_command("SessionDelete", M.delete, { desc = "Delete session for the launch directory" })
	-- `:Session <name>` names the session and `:Session -` clears the name,
	-- as `:Term 4 <name>` and `:Tab 4 <name>` do (there is one current
	-- session, so no number). Saved with the session, so the name is on
	-- disk once the session is (quit, :SessionSave).
	vim.api.nvim_create_user_command("Session", function(opts)
		local arg = vim.trim(opts.args)
		M.set_name(arg ~= "-" and arg or nil)
		notify(name and ("Session named " .. name) or "Session name cleared", vim.log.levels.INFO)
	end, { nargs = "+", bar = true, desc = "Name the current session (`-` clears it)" })
end

return M
