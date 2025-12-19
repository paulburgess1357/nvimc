-- Nvim-navic: Breadcrumb navigation showing current code context.
-- Displays class/function hierarchy in the statusline using LSP symbols.
local cfg = require("config.plugins").navic or {}
return {
	"SmiteshP/nvim-navic",
	enabled = cfg.enabled ~= false,
	branch = cfg.branch,
	dependencies = { "neovim/nvim-lspconfig" },
	opts = {
		lsp = {
			auto_attach = true,
			preference = nil,
		},
		highlight = true,
		separator = " > ",
		depth_limit = 0,
		depth_limit_indicator = "..",
		safe_output = true,
		lazy_update_context = true,
	},
}
