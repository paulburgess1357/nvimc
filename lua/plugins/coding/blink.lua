-- Blink.cmp: High-performance autocompletion engine written in Rust.
-- Provides fuzzy matching with typo resistance, frecency, and proximity scoring.
local cfg = require("config.plugins").blink or {}
return {
	"saghen/blink.cmp",
	enabled = cfg.enabled ~= false,
	branch = cfg.branch,
	dependencies = {
		"rafamadriz/friendly-snippets",
		"Kaiser-Yang/blink-cmp-avante",
	},
	version = "*",
	opts = {
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
		},
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
			per_filetype = {
				AvanteInput = { "avante", "buffer" },
			},
			providers = {
				avante = {
					module = "blink-cmp-avante",
					name = "Avante",
				},
			},
		},
		completion = {
			menu = {
				border = "rounded",
			},
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 200,
				window = {
					border = "rounded",
				},
			},
		},
		signature = {
			enabled = true,
			window = {
				border = "rounded",
			},
		},
		fuzzy = {
			implementation = "prefer_rust_with_warning",
		},
	},
	opts_extend = { "sources.default" },
}
