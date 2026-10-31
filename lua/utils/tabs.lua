-- Tab pages as a numbered list, named like the Term slots (utils.terms).
--
-- A Vim tab page is a window layout: each tab holds its own splits, and
-- the buffers (and the Term shells) are shared between tabs. Here the tabs
-- are a list that only grows at the end, each one a numbered workspace:
--
--   :NewTab [file]      a new tab after the last, showing the dashboard
--                       (or `file`). Plain :tabnew is rewritten to it.
--   :CloseTab [n|name]  close the current tab (or that one). Closing the
--                       last tab leaves one window with the dashboard,
--                       like a fresh start; the buffers stay loaded and
--                       the Term shells keep running, hidden, as they do
--                       behind any closed terminal window. Plain :tabclose
--                       is rewritten to it.
--   :Tab <n|name>       go to a tab. `:Tab <n> <name>` also names it and
--                       `:Tab <n> -` clears the name. `:Tab` alone: :Tabs.
--   :TabName [name|-]   name (or unname) the current tab
--   :Tabs               fzf-lua picker: each tab with what its windows
--                       show, the tab's current buffer in the preview
--                       (plugin/editor/fzf.lua)
--   H / L               previous / next tab (config/keymaps.lua)
--
-- A name lives in t:tabname (which lualine's tabs component reads too) and
-- shows as "Tab2 (build)" in the picker and "2 (build)" in the statusline
-- (plugin/ui/lualine.lua, only with two or more tabs; Vim's own tabline is
-- off). utils.session saves the names; :mksession saves the tabs and their
-- windows, and utils.terms the terminals in each.

local M = {}

local function tabpages()
	return vim.api.nvim_list_tabpages()
end

-- Tab handle for a 1-based number, nil if there is none.
local function handle(nr)
	return tabpages()[nr]
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

-- "Tab<n> (name)" for tab number nr, as the picker shows it.
function M.label(nr)
	return "Tab" .. M.short_label(nr)
end

-- "<n> (name)": the label without the word, for the statusline.
function M.short_label(nr)
	local name = M.name(handle(nr))
	return nr .. (name and (" (" .. name .. ")") or "")
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

-- Tab number for a `:Tab` argument: a number, or a name. nil if neither.
local function resolve(arg)
	local n = tonumber(arg)
	if n then return (n >= 1 and n <= #tabpages() and n == math.floor(n)) and n or nil end
	for nr, tab in ipairs(tabpages()) do
		if M.name(tab) == arg then return nr end
	end
end

local function complete(lead)
	local out = {}
	for nr, tab in ipairs(tabpages()) do
		out[#out + 1] = tostring(nr)
		local name = M.name(tab)
		if name then out[#out + 1] = name end
	end
	return vim.tbl_filter(function(c) return c:find(lead, 1, true) == 1 end, out)
end

local function no_such_tab(arg)
	vim.notify(("No tab %s (there are %d; :NewTab adds one)"):format(arg, #tabpages()), vim.log.levels.ERROR, { title = "Tabs" })
end

-- The dashboard in `win`, as Neovim starts: in the window's own buffer when
-- that is a fresh empty one (a new tab's, so no [No Name] buffer is left
-- behind in the buffer list), else in a new scratch buffer. Without snacks
-- the window is left as it is.
local function dashboard(win)
	if not (package.loaded["snacks"] and Snacks.dashboard) then return end
	local buf = vim.api.nvim_win_get_buf(win)
	local fresh = vim.api.nvim_buf_get_name(buf) == ""
		and vim.bo[buf].buftype == ""
		and not vim.bo[buf].modified
		and vim.api.nvim_buf_line_count(buf) == 1
		and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == ""
	Snacks.dashboard.open({ win = win, buf = fresh and buf or nil })
end

-- A new tab after the last one, with the dashboard, or `file` when given.
function M.new(file)
	vim.cmd("$tabnew")
	if file and file ~= "" then
		vim.cmd.edit(file)
	else
		dashboard(vim.api.nvim_get_current_win())
	end
end

-- Close tab number nr (default: the current one). The last tab is not
-- closed (Vim has no "no tabs"); its windows are closed down to one, which
-- gets the dashboard.
function M.close(nr)
	nr = nr or vim.fn.tabpagenr()
	if #tabpages() > 1 then
		vim.cmd(nr .. "tabclose")
		return
	end
	vim.cmd("silent! only")
	dashboard(vim.api.nvim_get_current_win())
end

function M.go(nr)
	local tab = handle(nr)
	if tab then vim.api.nvim_set_current_tabpage(tab) end
end

-- Names by tab number, { ["2"] = "build" }, for utils.session to save
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

-- Re-apply saved M.names(), once the session's tabs exist.
function M.restore(names)
	for nr, name in pairs(names) do
		local tab = handle(tonumber(nr))
		if tab and type(name) == "string" then M.set_name(tab, name) end
	end
end

function M.setup()
	local cmd = vim.api.nvim_create_user_command

	cmd("NewTab", function(opts) M.new(opts.args) end, {
		nargs = "?",
		bar = true,
		complete = "file",
		desc = "New tab after the last, with the dashboard (or a file)",
	})

	cmd("CloseTab", function(opts)
		local nr = vim.fn.tabpagenr()
		if opts.args ~= "" then
			nr = resolve(opts.args)
			if not nr then return no_such_tab(opts.args) end
		end
		M.close(nr)
	end, { nargs = "?", bar = true, complete = complete, desc = "Close the current tab (or tab <n|name>)" })

	-- `:Tab <n|name>` goes to the tab; `:Tab <n> <name>` also names it and
	-- `:Tab <n> -` clears the name (as `:Term<n> <name>` / `:Term<n> -`).
	cmd("Tab", function(opts)
		if opts.args == "" then
			if vim.fn.exists(":Tabs") == 2 then vim.cmd("Tabs") end
			return
		end
		local target, name = opts.args:match("^(%S+)%s*(.-)$")
		local nr = resolve(target)
		if not nr then return no_such_tab(target) end
		M.go(nr)
		if name ~= "" then M.set_name(handle(nr), name ~= "-" and name or nil) end
	end, { nargs = "*", bar = true, complete = complete, desc = "Go to tab <n|name>; `:Tab <n> <name>` names it" })

	cmd("TabName", function(opts)
		if opts.args == "" then
			vim.notify(M.label(vim.fn.tabpagenr()), vim.log.levels.INFO, { title = "Tabs" })
			return
		end
		M.set_name(0, opts.args ~= "-" and opts.args or nil)
	end, { nargs = "*", bar = true, desc = "Name the current tab (`-` clears it)" })

	-- `:tabnew` and `:tabclose` typed on their own become :NewTab and
	-- :CloseTab (so the new tab goes to the end with the dashboard, and the
	-- last tab can be "closed"), the way `:term9` becomes :Term9 in
	-- utils.terms: only when it is the whole command typed so far.
	for lower, upper in pairs({ tabnew = "NewTab", tabclose = "CloseTab" }) do
		vim.keymap.set("ca", lower, function()
			return (vim.fn.getcmdtype() == ":" and vim.fn.getcmdline() == lower) and upper or lower
		end, { expr = true })
	end
end

return M
