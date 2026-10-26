local plugins = require("config.plugins")
local cfg = plugins.blink or {}
local border = (plugins.settings or {}).border or "single"
if cfg.enabled == false then return end

require("blink.cmp").setup({
	keymap = {
		preset = "default",
		["<Tab>"] = {
			function(cmp)
				if cmp.snippet_active() then
					return cmp.accept()
				else
					return cmp.select_and_accept()
				end
			end,
			"snippet_forward",
			"fallback",
		},
		["<S-Tab>"] = { "snippet_backward", "fallback" },
		["<C-j>"] = { "select_next", "fallback" },
		["<C-k>"] = { "select_prev", "fallback" },
	},
	appearance = {
		nerd_font_variant = "mono",
		kind_icons = require("utils.icons").kinds, -- shared with aerial and fzf-lua
	},
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
	},
	completion = {
		menu = {
			border = border,
		},
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 200,
			window = {
				border = border,
			},
		},
	},
	signature = {
		enabled = true,
		window = {
			border = border,
		},
	},
	fuzzy = {
		implementation = "prefer_rust_with_warning",
	},
})
