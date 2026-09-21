local cfg = require("config.plugins").bufferline or {}
if cfg.enabled == false then return end

-- Buffer tabs in the tabline (replaces lualine's `buffers` component, which
-- cannot reorder). Colors are derived from the active colorscheme.
require("bufferline").setup({
	options = {
		mode = "buffers",
		diagnostics = false,
		show_buffer_close_icons = false,
		show_close_icon = false,
		always_show_bufferline = true,
		separator_style = "thin",
		modified_icon = "●",
	},
})

local keymap = vim.keymap

-- Cycle in VISUAL tab order. Plain :bnext/:bprevious follow buffer numbers,
-- which stops matching the tabline as soon as a tab has been moved.
keymap.set("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })
keymap.set("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })

-- Hold Ctrl+Shift and tap h/l to drag the current tab left/right.
-- Needs a terminal that reports Ctrl+Shift+letter (kitty does; its default
-- ctrl+shift+h / ctrl+shift+l bindings must be set to no_op in kitty.conf).
keymap.set("n", "<C-S-h>", "<cmd>BufferLineMovePrev<CR>", { desc = "Move buffer tab left" })
keymap.set("n", "<C-S-l>", "<cmd>BufferLineMoveNext<CR>", { desc = "Move buffer tab right" })
