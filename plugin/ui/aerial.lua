local plugins = require("config.plugins")
local cfg = plugins.aerial or {}
local settings = plugins.settings or {}
if cfg.enabled == false then return end

require("aerial").setup({
	backends = { "lsp", "treesitter", "markdown", "man" },
	icons = require("utils.ui").kinds, -- shared with blink and fzf-lua
	layout = {
		min_width = 30,
		default_direction = "left",
		placement = "edge",
	},
	attach_mode = "global",
	autojump = true,
	disable_max_lines = settings.aerial_max_lines or 50000,
	filter_kind = false,
	show_guides = true,
	guides = {
		mid_item = "├─",
		last_item = "└─",
		nested_top = "│ ",
		whitespace = "  ",
	},
})

vim.api.nvim_create_user_command("Aerials", "AerialToggle", { desc = "Toggle aerial sidebar" })

vim.keymap.set("n", "<leader>o", "<cmd>AerialToggle<cr>", { desc = "Outline" })
-- aerial's own fzf-lua picker (fzf-lua ships no "aerial" picker). A window
-- without a file (a terminal, quickfix) has no symbols: a notice, not
-- aerial's "no supported backend" error.
vim.keymap.set("n", "<leader>so", function()
	if vim.bo.buftype ~= "" then
		vim.notify("No symbols in this window", vim.log.levels.WARN, { title = "Outline" })
		return
	end
	require("aerial").fzf_lua_picker()
end, { desc = "Outline symbols" })
vim.keymap.set("n", "{", "<cmd>AerialPrev<cr>", { desc = "Previous symbol" })
vim.keymap.set("n", "}", "<cmd>AerialNext<cr>", { desc = "Next symbol" })
