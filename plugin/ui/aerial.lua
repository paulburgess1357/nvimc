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

-- Whether aerial has a symbol source for this buffer: an attached LSP or
-- a treesitter query for the language. Not for a terminal or quickfix
-- window, nor a file type aerial has no query for (.gitignore, plain text).
local function has_symbols()
	return require("aerial.backends").get(0) ~= nil
end

local function no_symbols()
	vim.notify("No symbols in this window", vim.log.levels.WARN, { title = "Outline" })
end

-- Toggle the outline; without a symbol source, the notice instead of an
-- empty pane. Closing an open outline works from anywhere.
vim.keymap.set("n", "<leader>o", function()
	if not has_symbols() and not require("aerial").is_open() then return no_symbols() end
	vim.cmd("AerialToggle")
end, { desc = "Outline" })
-- aerial's own fzf-lua picker (fzf-lua ships no "aerial" picker). Without a
-- symbol source: the notice, not aerial's "no supported backend" error.
vim.keymap.set("n", "<leader>so", function()
	if not has_symbols() then return no_symbols() end
	require("aerial").fzf_lua_picker()
end, { desc = "Outline symbols" })
vim.keymap.set("n", "{", "<cmd>AerialPrev<cr>", { desc = "Previous symbol" })
vim.keymap.set("n", "}", "<cmd>AerialNext<cr>", { desc = "Next symbol" })
