local plugins = require("config.plugins")
local cfg = plugins.snacks or {}
local settings = plugins.settings or {}
if cfg.enabled == false then return end

-----------------------------------------------------------
-- Dashboard gradient colors (adapts to colorscheme)
-----------------------------------------------------------
local function get_hl_fg(...)
	for _, name in ipairs({ ... }) do
		local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
		if hl.fg then return string.format("#%06x", hl.fg) end
	end
end

local gradient_hls = {
	{ "@keyword", "Keyword", "Statement" },
	{ "@function", "Function" },
	{ "@property", "@field", "Identifier" },
	{ "@string", "String" },
	{ "@type", "Type" },
	{ "@number", "@constant", "Constant", "Number" },
}

local function set_gradient_colors()
	for i, hls in ipairs(gradient_hls) do
		local color = get_hl_fg(unpack(hls)) or "#888888"
		vim.api.nvim_set_hl(0, "DashboardGradient" .. i, { fg = color })
	end
end

-----------------------------------------------------------
-- Dashboard header
-----------------------------------------------------------
local header_lines = {
	"███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
	"████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
	"██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
	"██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
	"██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
	"╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
}

local function make_header_sections()
	local sections = {}
	for i, line in ipairs(header_lines) do
		table.insert(sections, {
			text = { { line, hl = "DashboardGradient" .. i } },
			align = "center",
			padding = i == #header_lines and 1 or 0,
		})
	end
	table.insert(sections, { section = "keys", gap = 1, padding = 1 })
	return sections
end

-----------------------------------------------------------
-- Setup
-----------------------------------------------------------
set_gradient_colors()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_gradient_colors })

require("snacks").setup({
	bigfile = {
		enabled = true,
		notify = true,
		size = (settings.bigfile_max_mb or 1.5) * 1024 * 1024,
		setup = function()
			vim.cmd([[NoMatchParen]])
			vim.opt_local.swapfile = false
			vim.opt_local.foldmethod = "manual"
			vim.opt_local.undolevels = -1
			vim.opt_local.undoreload = 0
			vim.opt_local.list = false
		end,
	},
	dashboard = {
		enabled = true,
		preset = {
			keys = {
				{
					icon = "󰦛 ",
					key = "s",
					desc = "Restore Session",
					action = ":lua require('utils.session').restore()",
					enabled = function() return require("utils.session").exists() end,
				},
				{ icon = "󰋚 ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
				{ icon = "󰒓 ", key = "c", desc = "Config", action = ":e " .. vim.fn.stdpath("config") .. "/lua/config/plugins.lua" },
				{ icon = "󰚰 ", key = "u", desc = "Update Plugins", action = ":lua vim.pack.update()" },
				{ icon = "󰏖 ", key = "p", desc = "Browse Plugins", action = ":lua vim.pack.update(nil, { offline = true })" },
				{ icon = "󰓙 ", key = "h", desc = "Health Check", action = ":checkhealth" },
				{ icon = "󰩈 ", key = "q", desc = "Quit", action = ":qa" },
			},
		},
		sections = make_header_sections(),
	},
	indent = {
		enabled = true,
		indent = { char = "│", only_scope = false, only_current = false },
		scope = { enabled = true, char = "│", underline = false },
		animate = { enabled = true, duration = { step = 20, total = 300 } },
	},
	notifier = { enabled = false },
	scroll = { enabled = false },
	toggle = { enabled = true, which_key = true, notify = true },
})
