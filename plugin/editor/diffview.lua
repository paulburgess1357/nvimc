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
local AUTO_CLOSE_BROWSED_BUFFERS = true

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

require("diffview").setup({
	enhanced_diff_hl = true, -- richer add/change/delete highlighting in the diff
	view = {
		default = { winbar_info = false },
	},
	hooks = {
		-- Fallback snapshot for entry points that bypass our keymaps
		-- (e.g. `:DiffviewOpen main...HEAD` typed directly). No-ops when the
		-- feature is disabled, since snapshot_buffers() leaves the snapshot nil.
		view_opened = function()
			if not pre_diff_buffers then
				snapshot_buffers()
			end
		end,
		view_closed = cleanup_buffers,
	},
	-- `q` closes the diff from anywhere inside it (view or either panel).
	-- `<S-h>`/`<S-l>` are disabled so the global buffer-switch maps can't swap a
	-- normal buffer into a diffview window.
	keymaps = {
		view = {
			{ "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
			{ "n", "<S-h>", "<Nop>", { desc = "Disabled in diffview" } },
			{ "n", "<S-l>", "<Nop>", { desc = "Disabled in diffview" } },
		},
		file_panel = {
			{ "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
			{ "n", "<S-h>", "<Nop>", { desc = "Disabled in diffview" } },
			{ "n", "<S-l>", "<Nop>", { desc = "Disabled in diffview" } },
		},
		file_history_panel = {
			{ "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
			{ "n", "<S-h>", "<Nop>", { desc = "Disabled in diffview" } },
			{ "n", "<S-l>", "<Nop>", { desc = "Disabled in diffview" } },
		},
	},
})

-- Toggle the working-tree diff: open if nothing is showing, else close.
local function toggle_diffview()
	if next(require("diffview.lib").views) ~= nil then
		vim.cmd("DiffviewClose")
	else
		snapshot_buffers()
		vim.cmd("DiffviewOpen")
	end
end

vim.keymap.set("n", "<leader>gd", toggle_diffview, { desc = "Diff view (toggle)" })
vim.keymap.set("n", "<leader>gh", function()
	snapshot_buffers()
	vim.cmd("DiffviewFileHistory %")
end, { desc = "File history (current file)" })
