-- render-markdown.nvim: Render markdown with inline formatting in the buffer.
-- Displays headings, code blocks, tables, and callouts with visual styling.
local cfg = require("config.plugins").rendermarkdown or {}
return {
	"MeanderingProgrammer/render-markdown.nvim",
	enabled = cfg.enabled ~= false,
	branch = cfg.branch,
	ft = { "markdown", "codecompanion" },
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	opts = {
		enabled = true,
		render_modes = { "n", "c", "t" },
		max_file_size = 10.0,
		heading = {
			enabled = true,
			sign = true,
			icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
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
			unchecked = { icon = "󰄱 " },
			checked = { icon = "󰱒 " },
		},
		quote = {
			enabled = true,
			icon = "▋",
		},
		pipe_table = {
			enabled = true,
			style = "full",
		},
	},
	keys = {
		{ "<leader>um", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle markdown render" },
	},
}
