local plugins = require("config.plugins")
local cfg = plugins.blink or {}
local ui = require("utils.ui")
local border = ui.border
if cfg.enabled == false then return end

-- Set up once the first frame is drawn (utils.startup): blink validates its
-- whole config and checks its fuzzy-matcher binary at setup, none of which
-- the dashboard needs. Its keymaps are applied on InsertEnter, so a setup
-- a few milliseconds after startup changes nothing.
require("utils.startup").after(function()
require("blink.cmp").setup({
	-- The default preset (<C-space> menu, <C-e> hide, <C-y> accept, ...),
	-- plus Tab to accept and <C-j>/<C-k> to move, as in the fzf pickers.
	keymap = {
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
		kind_icons = ui.kinds, -- shared with aerial and fzf-lua
	},
	completion = {
		menu = {
			border = border,
			scrollbar = false, -- no float draws one (nor the doc and signature windows below)
			draw = {
				-- Labels colored by treesitter, so a function or a variable looks
				-- the same in the menu as in the buffer.
				treesitter = { "lsp" },
				-- Kind as the icon alone (the same glyph as aerial and the fzf
				-- symbol pickers), not "icon Function".
				columns = { { "label", "label_description", gap = 1 }, { "kind_icon" } },
				padding = ui.padding[2], -- the one column every float has
			},
		},
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 200,
			window = {
				border = border,
				scrollbar = false,
			},
		},
	},
	signature = {
		enabled = true,
		window = {
			border = border,
			scrollbar = false,
		},
	},
})
end)
