-- Tab pages as numbered slots, named and addressed like the Term slots
-- (utils.terms).
--
-- A Vim tab page is a window layout: each tab holds its own splits, and
-- the buffers (and the Term shells) are shared between tabs. Here each tab
-- is a numbered workspace, "Tab 4", and keeps its number for life, as Term 4
-- is always Term 4: closing Tab 2 leaves Tab 1 and Tab 3, and `:Tab 2` later
-- makes a new Tab 2 between them. Tabs are kept in slot order on screen.
--
--   :Tab <n>            go to Tab <n>, creating it (after the last lower
--                       slot, showing the dashboard) if there is none
--   :Tab <n> <name>     the same, and name it; `:Tab <n> -` clears the name
--   :Tab <name>         go to the tab named <name>
--   :CloseTab [n|name]  close the current tab (or that one). Closing the
--                       last tab leaves one window with the dashboard,
--                       like a fresh start; the buffers stay loaded and
--                       the Term shells keep running, hidden, as they do
--                       behind any closed terminal window. Also :TabClose.
--   :Tabs               fzf-lua picker: each tab with what its windows
--                       show, the tab's current buffer in the preview
--                       (plugin/editor/fzf.lua)
--   H / L               previous / next tab (config/keymaps.lua)
--
-- Lowercase is Neovim's: `:tabnew` and `:tabclose` do what they always do.
-- A tab made any other way (Neovim's :tabnew, diffview's diff tab) takes
-- the number after the highest in use, so every tab has one.
--
-- The slot lives in t:tabslot and the name in t:tabname (lualine's tabs
-- component reads both) and show as "Tab 2 (build)" in the picker and
-- "2 (build)" in the statusline (plugin/ui/lualine.lua, only with two or
-- more tabs; Vim's own tabline is off). utils.session saves slots and names
-- by tab position; :mksession saves the tabs and their windows, and
-- utils.terms the terminals in each.

local M = {}

local function tabpages()
	return vim.api.nvim_list_tabpages()
end

-- The tab's slot number (t:tabslot), nil when it has none yet. `tab` is a
-- handle, 0 for the current tab.
function M.slot(tab)
	local ok, n = pcall(vim.api.nvim_tabpage_get_var, tab or 0, "tabslot")
	return (ok and type(n) == "number") and n or nil
end

local function set_slot(tab, n)
	vim.api.nvim_tabpage_set_var(tab, "tabslot", n)
end

-- Handle of the tab in slot n, nil if there is none.
local function by_slot(n)
	for _, tab in ipairs(tabpages()) do
		if M.slot(tab) == n then return tab end
	end
end

-- Every tab without a slot gets the number after the highest in use, in
-- tab order: Neovim's own :tabnew, diffview's tab, the tabs of a session
-- saved before slots were recorded.
local function assign_slots()
	local max = 0
	for _, tab in ipairs(tabpages()) do
		max = math.max(max, M.slot(tab) or 0)
	end
	for _, tab in ipairs(tabpages()) do
		if not M.slot(tab) then
			max = max + 1
			set_slot(tab, max)
		end
	end
end

-- The tab's name (t:tabname), nil when it has none. `tab` is a handle, 0
-- for the current tab.
function M.name(tab)
	local ok, name = pcall(vim.api.nvim_tabpage_get_var, tab or 0, "tabname")
	return (ok and type(name) == "string" and name ~= "") and name or nil
end

function M.set_name(tab, name)
	if name and name ~= "" then
		vim.api.nvim_tabpage_set_var(tab, "tabname", name)
	else
		pcall(vim.api.nvim_tabpage_del_var, tab, "tabname")
	end
	-- The statusline shows the names; a rename is no event lualine watches.
	local ok, lualine = pcall(require, "lualine")
	if ok then lualine.refresh() end
end

-- "<n> (name)": the label without the word, for the statusline. `nr` is
-- the tab's position (what lualine's tabs component passes).
function M.short_label(nr)
	local tab = tabpages()[nr]
	if not tab then return tostring(nr) end
	local name = M.name(tab)
	return (M.slot(tab) or nr) .. (name and (" (" .. name .. ")") or "")
end

-- "Tab <n> (name)" for a tab handle, as the picker shows it.
function M.label(tab)
	return "Tab " .. M.short_label(vim.api.nvim_tabpage_get_number(tab))
end

-- What a tab's windows show, one short name each, in window order: a
-- file's name (● when modified), a Term label, a side window's name
-- (utils.ui.windows), the dashboard. Floats are left out.
function M.contents(tab)
	local ui = require("utils.ui")
	local terms = require("utils.terms")
	local out = {}
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
		if vim.api.nvim_win_get_config(win).relative == "" then
			local buf = vim.api.nvim_win_get_buf(win)
			local bt, ft = vim.bo[buf].buftype, vim.bo[buf].filetype
			local slot = bt == "terminal" and terms.slot_of(buf)
			local spec = ui.windows[ft]
			local item
			if slot then
				item = terms.label(slot)
			elseif spec then
				-- The side-window names read the window they are in (%:t, the
				-- list's title), so evaluate them there.
				item = type(spec.name) == "function" and vim.api.nvim_win_call(win, spec.name) or spec.name
			elseif ft == "snacks_dashboard" then
				item = "Dashboard"
			elseif bt == "terminal" then
				item = "terminal"
			else
				local name = vim.api.nvim_buf_get_name(buf)
				item = name ~= "" and vim.fn.fnamemodify(name, ":t") or "[No Name]"
				if vim.bo[buf].modified then item = item .. " ●" end
			end
			out[#out + 1] = item
		end
	end
	return out
end

-- A slot number from a command argument: a positive integer, else nil.
local function slot_arg(arg)
	local n = tonumber(arg)
	if n and n >= 1 and n == math.floor(n) then return n end
end

-- Tab handle for a `:Tab` / `:CloseTab` argument: a slot number, or a
-- name. nil if no tab has it.
local function resolve(arg)
	local n = slot_arg(arg)
	if n then return by_slot(n) end
	for _, tab in ipairs(tabpages()) do
		if M.name(tab) == arg then return tab end
	end
end

local function complete(lead)
	local out = {}
	for _, tab in ipairs(tabpages()) do
		out[#out + 1] = tostring(M.slot(tab))
		local name = M.name(tab)
		if name then out[#out + 1] = name end
	end
	return vim.tbl_filter(function(c) return c:find(lead, 1, true) == 1 end, out)
end

local function no_such_tab(arg)
	vim.notify("No tab named " .. arg, vim.log.levels.ERROR, { title = "Tabs" })
end

-- The dashboard in `win`, as Neovim starts: in the window's own buffer when
-- that is a fresh empty one (a new tab's, so no [No Name] buffer is left
-- behind in the buffer list), else in a new scratch buffer. Without snacks
-- the window is left as it is. Also used by utils.session for the tabs a
-- session brings back empty.
function M.dashboard(win)
	if not (package.loaded["snacks"] and Snacks.dashboard) then return end
	local buf = vim.api.nvim_win_get_buf(win)
	local fresh = vim.api.nvim_buf_get_name(buf) == ""
		and vim.bo[buf].buftype == ""
		and not vim.bo[buf].modified
		and vim.api.nvim_buf_line_count(buf) == 1
		and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == ""
	local dash = Snacks.dashboard.open({ win = win, buf = fresh and buf or nil })
	-- snacks keeps one autocommand group for "the" dashboard, cleared on
	-- every open and deleted when the dashboard's buffer is wiped. With a
	-- dashboard per tab that goes wrong both ways: the second one wiped finds
	-- the group gone and errors (E367), and the autocommands of the last one
	-- opened outlive its window in the shared group (its WinResized handler
	-- then errors on every resize, "Invalid window id"). So each dashboard
	-- gets a group of its own, holding its autocommands, moved out of the
	-- shared group, which is left empty.
	local shared = dash.augroup
	dash.augroup = vim.api.nvim_create_augroup("snacks_dashboard_" .. dash.buf, { clear = true })
	for _, a in ipairs(vim.api.nvim_get_autocmds({ group = shared })) do
		vim.api.nvim_create_autocmd(a.event, {
			group = dash.augroup,
			pattern = not a.buflocal and a.pattern or nil,
			buffer = a.buflocal and a.buffer or nil,
			callback = a.callback,
			command = not a.callback and a.command or nil,
			once = a.once,
			nested = a.nested,
			desc = a.desc,
		})
	end
	vim.api.nvim_create_augroup("snacks_dashboard", { clear = true })
end

-- Make Tab n: a new tab after the last tab with a lower slot, with the
-- dashboard. Returns its handle. The caller checks the slot is free.
function M.new(n)
	local after = 0
	for _, tab in ipairs(tabpages()) do
		if (M.slot(tab) or 0) < n then after = vim.api.nvim_tabpage_get_number(tab) end
	end
	vim.cmd(after .. "tabnew")
	local tab = vim.api.nvim_get_current_tabpage()
	set_slot(tab, n)
	M.dashboard(vim.api.nvim_get_current_win())
	return tab
end

-- Close a tab (default: the current one). The last tab is not closed (Vim
-- has no "no tabs"); its windows are closed down to one, which gets the
-- dashboard. Its slot stays, as a terminal's does.
function M.close(tab)
	tab = tab or vim.api.nvim_get_current_tabpage()
	if #tabpages() > 1 then
		vim.cmd(vim.api.nvim_tabpage_get_number(tab) .. "tabclose")
		return
	end
	vim.cmd("silent! only")
	M.dashboard(vim.api.nvim_get_current_win())
end

-- Go to Tab n, by slot, making it if there is none.
function M.go(n)
	local tab = by_slot(n) or M.new(n)
	vim.api.nvim_set_current_tabpage(tab)
	return tab
end

-- Names by tab position, { ["2"] = "build" }, for utils.session to save
-- (:mksession does not keep t: variables). String keys: a list with holes
-- does not survive JSON.
function M.names()
	local out = {}
	for nr, tab in ipairs(tabpages()) do
		local name = M.name(tab)
		if name then out[tostring(nr)] = name end
	end
	return out
end

-- Slots by tab position, { ["1"] = 1, ["2"] = 4 }, for utils.session.
function M.slots()
	local out = {}
	for nr, tab in ipairs(tabpages()) do
		out[tostring(nr)] = M.slot(tab)
	end
	return out
end

-- Re-apply saved M.names() and M.slots(), once the session's tabs exist. A
-- session from before slots were saved numbers its tabs by position.
function M.restore(names, slots)
	local tabs = tabpages()
	for nr, n in pairs(slots or {}) do
		local tab = tabs[tonumber(nr)]
		if tab and type(n) == "number" then set_slot(tab, n) end
	end
	assign_slots()
	for nr, name in pairs(names or {}) do
		local tab = tabs[tonumber(nr)]
		if tab and type(name) == "string" then M.set_name(tab, name) end
	end
end

function M.setup()
	local cmd = vim.api.nvim_create_user_command

	-- The first tab is Tab 1; any tab made outside `:Tab <n>` gets the next
	-- number as it appears.
	assign_slots()
	vim.api.nvim_create_autocmd("TabNew", { callback = assign_slots, desc = "Number a new tab page" })

	-- `:Tab <n>` goes to Tab n, making it if there is none; `:Tab <n> <name>`
	-- also names it and `:Tab <n> -` clears the name, as `:Term <n>`,
	-- `:Term <n> <name>` and `:Term <n> -`. `:Tab <name>` goes to the tab
	-- named so (the whole argument, so a name can have spaces).
	cmd("Tab", function(opts)
		local args = vim.trim(opts.args)
		local first, rest = args:match("^(%S+)%s*(.-)$")
		local n = slot_arg(first)
		if n then
			local tab = M.go(n)
			if rest ~= "" then M.set_name(tab, rest ~= "-" and rest or nil) end
			return
		end
		local tab = resolve(args)
		if not tab then return no_such_tab(args) end
		vim.api.nvim_set_current_tabpage(tab)
	end, { nargs = "+", bar = true, complete = complete, desc = "Go to (or make) Tab <n>, naming it with <name>; or go to Tab <name>" })

	-- :CloseTab and :TabClose, both word orders.
	local function close_tab(opts)
		local tab
		if opts.args ~= "" then
			tab = resolve(opts.args)
			if not tab then return no_such_tab(opts.args) end
		end
		M.close(tab)
	end
	local close_opts = { nargs = "?", bar = true, complete = complete, desc = "Close the current tab (or Tab <n|name>)" }
	cmd("CloseTab", close_tab, close_opts)
	cmd("TabClose", close_tab, close_opts)
end

return M
