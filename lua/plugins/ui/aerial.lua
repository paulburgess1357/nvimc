-- aerial.nvim: Code outline sidebar showing symbols from LSP/treesitter.
-- Navigate and jump to functions, classes, and other code structures.
local cfg = require("config.plugins").aerial or {}
return {
	"stevearc/aerial.nvim",
	enabled = cfg.enabled ~= false,
	branch = cfg.branch,
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	cmd = { "AerialToggle", "AerialOpen", "AerialNavToggle", "Aerials" },
	config = function(_, opts)
		require("aerial").setup(opts)
		vim.api.nvim_create_user_command("Aerials", "AerialToggle", { desc = "Toggle aerial sidebar" })
	end,
	opts = {
		backends = { "lsp", "treesitter", "markdown", "man" },
		layout = {
			min_width = 30,
			default_direction = "left",
		},
		attach_mode = "global",
		filter_kind = false,
		show_guides = true,
		guides = {
			mid_item = "├─",
			last_item = "└─",
			nested_top = "│ ",
			whitespace = "  ",
		},
	},
	keys = {
		{ "<leader>o", "<cmd>AerialToggle<cr>", desc = "Outline (Aerial)" },
		{ "<leader>so", "<cmd>FzfLua aerial<cr>", desc = "Outline symbols" },
		{ "{", "<cmd>AerialPrev<cr>", desc = "Previous symbol" },
		{ "}", "<cmd>AerialNext<cr>", desc = "Next symbol" },
	},
}
