local plugins = require("config.plugins")
local cfg = plugins.blink or {}
local border = require("utils.ui").border
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
		kind_icons = require("utils.ui").kinds, -- shared with aerial and fzf-lua
	},
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
	},
	completion = {
		menu = {
			border = border,
			draw = {
				-- Labels colored by treesitter, so a function or a variable looks
				-- the same in the menu as in the buffer.
				treesitter = { "lsp" },
				-- Kind as the icon alone (the same glyph as aerial and the fzf
				-- symbol pickers), not "icon Function".
				columns = { { "label", "label_description", gap = 1 }, { "kind_icon" } },
			},
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
