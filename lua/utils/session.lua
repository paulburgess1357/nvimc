local M = {}

-- One session per launch directory, saved automatically on quit and restored
-- on demand (dashboard `s` / :SessionRestore). Built on :mksession, no plugin.
--
-- Files live in stdpath("state")/sessions/, named after the directory Neovim
-- was STARTED in (a later :cd does not change which session is written):
--   <dir>.vim   the :mksession script
--   <dir>.json  what :mksession can't see: buffer-tab order (utils.buftabs)
--               and the visible terminals (M.term)

-- No `blank` / `terminal`: nofile plugin windows (aerial, dap-ui, ...) can't
-- be revived, and terminals are respawned through M.term instead.
vim.o.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize"

local dir = vim.fn.stdpath("state") .. "/sessions/"
local base = dir .. vim.fn.getcwd():gsub("[/\\:]", "%%")

-- Terminal provider, registered by plugin/ui/snacks.lua:
--   { close_all = fun(), snapshot = fun(): table, restore = fun(terms: table) }
M.term = nil

local deleted = false

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
	vim.fn.mkdir(dir, "p")
	vim.cmd("mksession! " .. vim.fn.fnameescape(base .. ".vim"))
	local extra = {
		tabs = require("utils.buftabs").names(),
		terms = M.term and M.term.snapshot() or {},
	}
	vim.fn.writefile({ vim.json.encode(extra) }, base .. ".json")
end

function M.restore()
	if not M.exists() then
		vim.notify("No session for " .. vim.fn.getcwd(), vim.log.levels.WARN)
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
	if M.term and type(extra.terms) == "table" then M.term.restore(extra.terms) end
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
