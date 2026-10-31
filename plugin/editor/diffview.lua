local cfg = require("config.plugins").diffview or {}
if cfg.enabled == false then
	return
end

-- ===========================================================================
-- Auto-close browsed buffers  (toggle with the flag below)
--
-- Diffview loads every file you open in a diff as a real, listed buffer. After
-- :DiffviewClose those stay loaded -- they pile up in :ls and the tabline. When
-- enabled, this snapshots the listed buffers before a diff opens and wipes
-- anything diffview added once it closes (never touching modified or visible
-- buffers, or buffers that already existed). Set to false to keep stock
-- behavior (browsed files remain open).
-- ===========================================================================
local AUTO_CLOSE_BROWSED_BUFFERS = false

local pre_diff_buffers = nil

local function snapshot_buffers()
	if not AUTO_CLOSE_BROWSED_BUFFERS then
		return
	end
	pre_diff_buffers = {}
	for _, b in ipairs(vim.api.nvim_list_bufs()) do
		if vim.bo[b].buflisted then
			pre_diff_buffers[b] = true
		end
	end
end

local function cleanup_buffers()
	if not pre_diff_buffers then
		return
	end
	for _, b in ipairs(vim.api.nvim_list_bufs()) do
		if
			vim.api.nvim_buf_is_valid(b)
			and vim.bo[b].buflisted
			and vim.bo[b].buftype == "" -- only real file buffers
			and not pre_diff_buffers[b] -- introduced by this diff session
			and not vim.bo[b].modified -- never drop unsaved work
			and vim.fn.bufwinid(b) == -1 -- not currently displayed anywhere
		then
			pcall(vim.api.nvim_buf_delete, b, { force = false })
		end
	end
	pre_diff_buffers = nil
end
-- ===========================================================================

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
		-- Fallback snapshot for entry points that bypass our keymaps
		-- (e.g. `:DiffviewOpen main...HEAD` typed directly). No-ops when the
		-- feature is disabled, since snapshot_buffers() leaves the snapshot nil.
		--
		-- Diffview opens in a tab page it makes with `:tab split`, which puts
		-- it right after the current tab and renumbers every tab behind it.
		-- The tabs are a numbered list that only grows at the end (utils.tabs),
		-- so the diff tab is moved to the end and named, "3 (diff)" or
		-- "3 (history)" in the statusline. Closing the diff removes it again.
		view_opened = function(view)
			if not pre_diff_buffers then
				snapshot_buffers()
			end
			vim.cmd("tabmove $")
			local kind = view and view.class and view.class.__name
			require("utils.tabs").set_name(0, kind == "FileHistoryView" and "history" or "diff")
		end,
		view_closed = cleanup_buffers,
	},
	-- `q` closes the diff from anywhere inside it (view or either panel).
	-- `<leader><leader>e` is disabled so the buffer popup can't swap a normal
	-- buffer into a diffview window. (`<leader>e` is diffview's own "focus the
	-- file panel" there, not the explorer, for the same reason.)
	-- `L` is diffview's "open commit log" in both panels; that would shadow
	-- the global L (next tab, config/keymaps.lua), so it is dropped and the
	-- commit log moves to gL. H is untouched by diffview, so both work.
	keymaps = {
		view = {
			{ "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
			{ "n", "<leader><leader>e", "<Nop>", { desc = "Disabled in diffview" } },
		},
		file_panel = {
			{ "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
			{ "n", "<leader><leader>e", "<Nop>", { desc = "Disabled in diffview" } },
			{ "n", "L", false },
			{ "n", "gL", actions.open_commit_log, { desc = "Open the commit log" } },
		},
		file_history_panel = {
			{ "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
			{ "n", "<leader><leader>e", "<Nop>", { desc = "Disabled in diffview" } },
			{ "n", "L", false },
			{ "n", "gL", actions.open_commit_log, { desc = "Open the commit log" } },
		},
	},
})

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
	snapshot_buffers()
	vim.cmd("DiffviewOpen")
end

vim.keymap.set("n", "<leader>gd", toggle_diffview, { desc = "Diff view (toggle)" })
vim.keymap.set("n", "<leader>gh", function()
	snapshot_buffers()
	vim.cmd("DiffviewFileHistory %")
end, { desc = "File history (current file)" })

-- Review the current branch against a base ref (PR-style): prompts for the
-- base, then diffs merge-base(base, HEAD)..HEAD -- only this branch's changes.
vim.keymap.set("n", "<leader><leader>d", function()
	vim.ui.input({ prompt = "Review against: " }, function(base)
		if not base or base == "" then
			return
		end
		snapshot_buffers()
		vim.cmd("DiffviewOpen " .. vim.fn.fnameescape(base) .. "...HEAD")
	end)
end, { desc = "Review branch vs base" })
