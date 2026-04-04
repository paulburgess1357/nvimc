local cfg = require("config.plugins").increname or {}
if cfg.enabled == false then return end

require("inc_rename").setup({
	preview_empty_name = false,
	show_message = true,
	save_in_cmdline_history = true,
})

vim.keymap.set("n", "<leader>cr", function()
	return ":IncRename " .. vim.fn.expand("<cword>")
end, { expr = true, desc = "Rename (inc-rename)" })
