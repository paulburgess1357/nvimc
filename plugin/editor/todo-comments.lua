local cfg = require("config.plugins").todocomments or {}
if cfg.enabled == false then return end

require("todo-comments").setup({
	signs = true,
	sign_priority = 8,
	keywords = {
		FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
		TODO = { icon = " ", color = "info" },
		HACK = { icon = " ", color = "warning" },
		WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
		PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
		NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
		TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
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
