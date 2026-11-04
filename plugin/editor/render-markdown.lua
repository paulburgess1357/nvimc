local cfg = require("config.plugins").rendermarkdown or {}
if cfg.enabled == false then return end

-- render-markdown's defaults, less the sign column marks and the heading
-- icons, with a thin border on code blocks and Material checkboxes.
require("render-markdown").setup({
	sign = { enabled = false },
	heading = {
		sign = false,
		icons = {},
	},
	code = { border = "thin" },
	checkbox = {
		unchecked = { icon = "\u{F0131} " }, -- md-checkbox_blank_outline
		checked = { icon = "\u{F0C52} " }, -- md-checkbox_outline
	},
})

vim.keymap.set("n", "<leader>um", "<cmd>RenderMarkdown toggle<cr>", { desc = "Toggle markdown render" })
