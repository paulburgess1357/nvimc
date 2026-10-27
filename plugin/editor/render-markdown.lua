local cfg = require("config.plugins").rendermarkdown or {}
if cfg.enabled == false then return end

require("render-markdown").setup({
	enabled = true,
	render_modes = { "n", "c", "t" },
	max_file_size = 10.0,
	sign = { enabled = false },
	heading = {
		enabled = true,
		sign = false,
		icons = {},
	},
	code = {
		enabled = true,
		sign = true,
		style = "full",
		width = "full",
		border = "thin",
	},
	bullet = {
		enabled = true,
		icons = { "●", "○", "◆", "◇" },
	},
	checkbox = {
		enabled = true,
		unchecked = { icon = "\u{F0131} " }, -- md-checkbox_blank_outline
		checked = { icon = "\u{F0C52} " }, -- md-checkbox_outline
	},
	quote = {
		enabled = true,
		icon = "▋",
	},
	pipe_table = {
		enabled = true,
		style = "full",
	},
})

vim.keymap.set("n", "<leader>um", "<cmd>RenderMarkdown toggle<cr>", { desc = "Toggle markdown render" })
