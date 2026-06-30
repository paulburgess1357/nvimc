local cfg = require("config.plugins").diffview or {}
if cfg.enabled == false then return end

require("diffview").setup({
	enhanced_diff_hl = true, -- richer add/change/delete highlighting in the diff
	view = {
		default = { winbar_info = false },
	},
	-- `q` closes the diff from anywhere inside it (view or either panel).
	keymaps = {
		view = {
			{ "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
		},
		file_panel = {
			{ "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
		},
		file_history_panel = {
			{ "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
		},
	},
})

-- Toggle the working-tree diff: open if nothing is showing, else close.
local function toggle_diffview()
	if next(require("diffview.lib").views) ~= nil then
		vim.cmd("DiffviewClose")
	else
		vim.cmd("DiffviewOpen")
	end
end

vim.keymap.set("n", "<leader>gd", toggle_diffview, { desc = "Diff view (toggle)" })
vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "File history (current file)" })
