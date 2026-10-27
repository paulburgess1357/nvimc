local cfg = require("config.plugins").todocomments or {}
if cfg.enabled == false then return end

-- Keyword icons: Material, like every other pictogram (see utils.ui).
require("todo-comments").setup({
	signs = true,
	sign_priority = 8,
	keywords = {
		FIX = { icon = "\u{F00E4} ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } }, -- md-bug
		TODO = { icon = "\u{F012C} ", color = "info" }, -- md-check
		HACK = { icon = "\u{F0238} ", color = "warning" }, -- md-fire
		WARN = { icon = "\u{F002A} ", color = "warning", alt = { "WARNING", "XXX" } }, -- md-alert_outline
		PERF = { icon = "\u{F140B} ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } }, -- md-lightning_bolt
		NOTE = { icon = "\u{F039A} ", color = "hint", alt = { "INFO" } }, -- md-note
		TEST = { icon = "\u{F0668} ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } }, -- md-test_tube
	},
	merge_keywords = true,
	highlight = {
		multiline = true,
		before = "",
		keyword = "wide",
		after = "fg",
		pattern = [[.*<(KEYWORDS)\s*:]],
		comments_only = true,
		max_line_len = 400,
	},
})

vim.keymap.set("n", "]t", function()
	require("todo-comments").jump_next()
end, { desc = "Next todo comment" })

vim.keymap.set("n", "[t", function()
	require("todo-comments").jump_prev()
end, { desc = "Previous todo comment" })

vim.keymap.set("n", "<leader>st", "<cmd>TodoFzfLua<cr>", { desc = "Todo comments" })
vim.keymap.set("n", "<leader>sT", "<cmd>TodoFzfLua keywords=TODO,FIX,FIXME<cr>", { desc = "Todo/Fix/Fixme" })
