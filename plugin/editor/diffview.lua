local cfg = require("config.plugins").diffview or {}
if cfg.enabled == false then
	return
end

-- The configuration once the first frame is drawn (utils.startup); the
-- :Diffview commands exist from the start and the keymaps below load the
-- plugin when pressed.
require("utils.startup").after(function()
local actions = require("diffview.actions")

require("diffview").setup({
	enhanced_diff_hl = true, -- richer add/change/delete highlighting in the diff
	-- File panel pictograms: Material, like every other (see utils.ui).
	icons = {
		folder_closed = "\u{F024B}", -- md-folder
		folder_open = "\u{F0770}", -- md-folder_open
	},
	signs = {
		fold_closed = "\u{F0142}", -- md-chevron_right
		fold_open = "\u{F0140}", -- md-chevron_down
		done = "\u{F012C}", -- md-check
	},
	view = {
		default = { winbar_info = false },
	},
	hooks = {
		-- Diffview opens in a tab page it makes with `:tab split`, which puts
		-- it right after the current tab and renumbers every tab behind it.
		-- The tabs are a numbered list that only grows at the end (utils.tabs),
		-- so the diff tab is moved to the end and named, "3 (diff)" or
		-- "3 (history)" in the statusline. Closing the diff removes it again.
		view_opened = function(view)
			vim.cmd("tabmove $")
			local kind = view and view.class and view.class.__name
			require("utils.tabs").set_name(0, kind == "FileHistoryView" and "history" or "diff")
			-- Coming back to the tab (H / L) leaves the file panel as it was.
			-- Diffview's own tab_enter re-shows the current file with the
			-- cursor put on it in the panel, which opens the folder it is in
			-- if closed, and then refreshes, which does the same once more.
			-- Replaced with the same two steps while the panel holds its
			-- folds and cursor (FilePanel.highlight_file below) until the
			-- refresh is done, or a second at most.
			if kind ~= "DiffView" then return end
			local emitter = view.emitter
			for _, l in ipairs(emitter:get("tab_enter") or {}) do
				emitter:off(l.callback, "tab_enter")
			end
			emitter:on("tab_enter", function()
				view.panel.hold_folds_until = vim.uv.now() + 1000
				local file = view.panel.cur_file
				if file then view:set_file(file, false, false) end
				if view.ready then
					view:update_files(function() view.panel.hold_folds_until = nil end)
				else
					view.panel.hold_folds_until = nil
				end
			end)
		end,
	},
	-- `q` closes the diff from anywhere inside it (view or either panel).
	-- `<leader><leader>e` is disabled so the buffer popup can't swap a normal
	-- buffer into a diffview window. (`<leader>e` is diffview's own "focus the
	-- file panel" there, not the explorer, for the same reason.)
	-- `L` is diffview's "open commit log" in both panels; that would shadow
	-- the global L (next tab, config/keymaps.lua), so it is dropped and the
	-- commit log moves to gL. H is untouched by diffview, so both work.
	-- `<leader>o` shows / hides the file panel, as it toggles the outline
	-- (aerial, plugin/ui/aerial.lua) everywhere else: the side pane of
	-- wherever you are. Diffview's maps are buffer-local, so inside the diff
	-- this one wins; outside it <leader>o is still the outline.
	keymaps = {
		view = {
			{ "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
			{ "n", "<leader><leader>e", "<Nop>", { desc = "Disabled in diffview" } },
			{ "n", "<leader>o", actions.toggle_files, { desc = "Toggle the file panel" } },
		},
		file_panel = {
			{ "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
			{ "n", "<leader><leader>e", "<Nop>", { desc = "Disabled in diffview" } },
			{ "n", "<leader>o", actions.toggle_files, { desc = "Toggle the file panel" } },
			{ "n", "L", false },
			{ "n", "gL", actions.open_commit_log, { desc = "Open the commit log" } },
		},
		file_history_panel = {
			{ "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
			{ "n", "<leader><leader>e", "<Nop>", { desc = "Disabled in diffview" } },
			{ "n", "<leader>o", actions.toggle_files, { desc = "Toggle the file panel" } },
			{ "n", "L", false },
			{ "n", "gL", actions.open_commit_log, { desc = "Open the commit log" } },
		},
	},
})

-- Closed folders in the file panel stay closed across a refresh. Diffview
-- refreshes the file list on every save, index change and re-entry of its
-- tab (H / L and back), and each time it rebuilds the panel's folder tree
-- with every folder open, so the ones you had closed come back open. Here
-- the closed folders are noted by path before the rebuild and closed again
-- after it, per section (changes / staged). Diffview still opens the
-- folder of the file on screen, to point at it, as it did before.
local FilePanel = require("diffview.scene.views.diff.file_panel").FilePanel
local update_components = FilePanel.update_components
local SECTIONS = { "conflicting", "working", "staged" }
-- While a tab re-entry (the view_opened hook above) is settling, the panel
-- neither opens the current file's folder nor moves its cursor.
local highlight_file = FilePanel.highlight_file
function FilePanel:highlight_file(...)
	if self.hold_folds_until and vim.uv.now() < self.hold_folds_until then return end
	return highlight_file(self, ...)
end
function FilePanel:update_components(...)
	local closed = {}
	for i, section in ipairs(SECTIONS) do
		local files = self.components and self.components[section] and self.components[section].files
		if files and files.comp then
			closed[i] = {}
			files.comp:deep_some(function(comp)
				if comp.name == "directory" and comp.context and comp.context.collapsed then
					closed[i][comp.context.path] = true
				end
			end)
		end
	end
	local ret = update_components(self, ...)
	for i, section in ipairs(SECTIONS) do
		local files = closed[i] and self.components[section] and self.components[section].files
		if files and files.comp then
			files.comp:deep_some(function(comp)
				if comp.name == "directory" and comp.context and closed[i][comp.context.path] then
					comp.context.collapsed = true
				end
			end)
		end
	end
	return ret
end
end)

-- Toggle the working-tree diff: open if nothing is showing, else close.
-- The diff lives in its own tab, so from another tab (after H / L) a diff
-- that is still open is brought back first; :DiffviewClose only closes the
-- diff of the current tab and would be a no-op anywhere else.
local function toggle_diffview()
	local lib = require("diffview.lib")
	if lib.get_current_view() then
		vim.cmd("DiffviewClose")
		return
	end
	local view = lib.views[1]
	if view and view.tabpage and vim.api.nvim_tabpage_is_valid(view.tabpage) then
		vim.api.nvim_set_current_tabpage(view.tabpage)
		return
	end
	vim.cmd("DiffviewOpen")
end

vim.keymap.set("n", "<leader>gd", toggle_diffview, { desc = "Diff view (toggle)" })
vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "File history (current file)" })

-- Review the current branch against a base ref (PR-style): prompts for the
-- base, then diffs merge-base(base, HEAD)..HEAD -- only this branch's changes.
vim.keymap.set("n", "<leader><leader>d", function()
	vim.ui.input({ prompt = "Review against: " }, function(base)
		if not base or base == "" then
			return
		end
		vim.cmd("DiffviewOpen " .. vim.fn.fnameescape(base) .. "...HEAD")
	end)
end, { desc = "Review branch vs base" })
