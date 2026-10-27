local plugins = require("config.plugins")
local cfg = plugins.snacks or {}
local settings = plugins.settings or {}
if cfg.enabled == false then return end

local ui = require("utils.ui")

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
					icon = "\u{F09DB} ", -- md-chevron_right_box_outline
					key = "s",
					desc = "Restore session",
					action = ":lua require('utils.session').restore()",
					enabled = function() return require("utils.session").exists() end,
				},
				{ icon = "\u{F02DA} ", key = "r", desc = "Recent files", action = ":lua Snacks.dashboard.pick('oldfiles')" }, -- md-history
				{ icon = "\u{F0493} ", key = "c", desc = "Config", action = ":e " .. vim.fn.stdpath("config") .. "/lua/config/plugins.lua" }, -- md-cog
				{ icon = "\u{F06B0} ", key = "u", desc = "Update plugins", action = ":lua vim.pack.update()" }, -- md-update
				{ icon = "\u{F03D6} ", key = "p", desc = "Browse plugins", action = ":lua vim.pack.update(nil, { offline = true })" }, -- md-package_variant
				{ icon = "\u{F04D9} ", key = "h", desc = "Health check", action = ":checkhealth" }, -- md-stethoscope
				{ icon = "\u{F0A48} ", key = "q", desc = "Quit", action = ":qa" }, -- md-exit_run
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
	-- Notifications, top right, as small floats in the usual border with the
	-- level's icon and title; the border takes the level's diagnostic color.
	notifier = {
		enabled = true,
		timeout = 3000,
		-- The same level glyphs as the gutter and lualine (utils.ui), stated
		-- rather than relying on snacks' defaults matching.
		icons = {
			error = ui.diagnostics.error .. " ",
			warn = ui.diagnostics.warn .. " ",
			info = ui.diagnostics.info .. " ",
			debug = "\u{F00E4} ", -- md-bug
			trace = "\u{F03EB} ", -- md-pencil
		},
		top_down = true,
		-- snacks' "compact" style with the title on the left like the other floats.
		style = function(buf, notif, ctx)
			local title = vim.trim(notif.icon .. " " .. (notif.title or ""))
			if title ~= "" then
				ctx.opts.title = { { " " .. title .. " ", ctx.hl.title } }
				ctx.opts.title_pos = "left"
			end
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(notif.msg, "\n"))
		end,
	},
	scroll = { enabled = false },
	-- Zoom (<leader><leader>z): the buffer in a full-size float. The shared
	-- border frames it, and it keeps its winbar (utils.winbar / utils.terms
	-- allow it on this float), so it is titled like the window it came from.
	zen = { zoom = { win = { border = ui.border } } },
	toggle = { enabled = true, which_key = true, notify = true },
})
