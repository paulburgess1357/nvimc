local cfg = require("config.plugins").spider or {}
if cfg.enabled == false then return end

require("spider").setup({
	skipInsignificantPunctuation = true,
	subwordMovement = true,
	consistentOperatorPending = false,
})

vim.keymap.set({ "n", "o", "x" }, "w", "<cmd>lua require('spider').motion('w')<cr>", { desc = "Spider w" })
vim.keymap.set({ "n", "o", "x" }, "e", "<cmd>lua require('spider').motion('e')<cr>", { desc = "Spider e" })
vim.keymap.set({ "n", "o", "x" }, "b", "<cmd>lua require('spider').motion('b')<cr>", { desc = "Spider b" })
