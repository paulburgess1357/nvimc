local plugins = require("config.plugins")
local cfg = plugins.snacks or {}
local settings = plugins.settings or {}
if cfg.enabled == false then return end

local ui = require("utils.ui")

-----------------------------------------------------------
-- Dashboard header gradient. Six colors, one per header line, top to
-- bottom. One palette is picked per start: at random, or the one named by
-- settings.dashboard_gradient. "theme" is not a fixed palette but the
-- colorscheme's own syntax colors, so it follows the theme. `:Dashboard
-- [name]` reopens the dashboard with a palette, to browse them.
-----------------------------------------------------------
local gradients = {
	sunset = { "#ffd166", "#ff9f43", "#ff6b6b", "#ee5a6f", "#c44569", "#8e44ad" },
	ocean = { "#a8e6ff", "#5dd6ff", "#2bb5f5", "#1e90ff", "#1560bd", "#0b3d91" },
	forest = { "#d4f5a8", "#a8e063", "#6ab04c", "#3b8d3c", "#2b6b2f", "#1b4d24" },
	aurora = { "#7dffb3", "#4ee6c1", "#35c9d6", "#4aa8ff", "#7b6bff", "#b45cff" },
	lava = { "#fff1b5", "#ffd166", "#ff9f1c", "#ff6a00", "#e63900", "#8b0000" },
	ice = { "#ffffff", "#e6f7ff", "#bfe9ff", "#8fd3ff", "#5fb8f0", "#3a86c8" },
	neon = { "#39ff14", "#00ffd0", "#00c8ff", "#7a5cff", "#ff2bd6", "#ff2d55" },
	candy = { "#ffb3de", "#ff8fcf", "#ff6ec7", "#d46bff", "#a66cff", "#7d6bff" },
	ember = { "#fde68a", "#fbbf24", "#f59e0b", "#ea580c", "#c2410c", "#7c2d12" },
	mint = { "#e0fff4", "#b3f5d6", "#80e8b8", "#4fd19a", "#2bb67c", "#1a8a5c" },
	twilight = { "#f9c5d1", "#e6a3c9", "#c084cf", "#9b6bd1", "#6d5bd0", "#3f4fc9" },
	grape = { "#e9d5ff", "#c4b5fd", "#a78bfa", "#8b5cf6", "#7c3aed", "#5b21b6" },
	desert = { "#fff3d6", "#f5d9a6", "#e9b872", "#d9924a", "#b86b2c", "#7a4419" },
	midnight = { "#c7d2fe", "#818cf8", "#6366f1", "#4338ca", "#312e81", "#1e1b4b" },
	rose = { "#ffe4e6", "#fecdd3", "#fda4af", "#fb7185", "#f43f5e", "#be123c" },
	slate = { "#f1f5f9", "#cbd5e1", "#94a3b8", "#64748b", "#475569", "#1e293b" },
	cherry = { "#ffb7b2", "#ff8e8e", "#ff5d5d", "#e63946", "#b5172e", "#7a0c1f" },
	sky = { "#e0f2fe", "#bae6fd", "#7dd3fc", "#38bdf8", "#0ea5e9", "#0369a1" },
	lime = { "#f7ffe0", "#e3ff9e", "#c6f56b", "#a3e635", "#65a30d", "#3f6212" },
	coral = { "#ffe8d6", "#ffc8a2", "#ffa47a", "#ff7f50", "#e85d3a", "#b43c21" },
	teal = { "#ccfbf1", "#99f6e4", "#5eead4", "#2dd4bf", "#14b8a6", "#0f766e" },
	gold = { "#fffbe6", "#fff1a8", "#ffe066", "#ffcc00", "#e6a800", "#a37400" },
	steel = { "#e2e8f0", "#b8c4d6", "#8fa1ba", "#6b7f9e", "#4b5d7a", "#2f3c52" },
	flamingo = { "#ffd1dc", "#ffadc6", "#ff85b3", "#ff5c9e", "#f03a84", "#c21d66" },
	moss = { "#eef5d9", "#cfe3a8", "#a9c77a", "#86a855", "#647f3a", "#434f2a" },
	cyberpunk = { "#fcee0a", "#ff9e00", "#ff2a6d", "#d300c5", "#7a04eb", "#05d9e8" },
	vapor = { "#ffb3f0", "#d9a8ff", "#a8c8ff", "#8ef0ff", "#a8ffe0", "#ffe6a8" },
	rainbow = { "#ff5f5f", "#ffa94d", "#ffe066", "#8ce99a", "#66d9e8", "#9775fa" },
	copper = { "#fbe8d3", "#f1c9a5", "#e2a978", "#c98551", "#a3623a", "#6e3f24" },
}

-- The colorscheme's syntax colors, one highlight group per header line.
local function theme_gradient()
	local groups = {
		{ "@keyword", "Keyword", "Statement" },
		{ "@function", "Function" },
		{ "@property", "@field", "Identifier" },
		{ "@string", "String" },
		{ "@type", "Type" },
		{ "@number", "@constant", "Constant", "Number" },
	}
	local out = {}
	for i, names in ipairs(groups) do
		out[i] = "#888888"
		for _, name in ipairs(names) do
			local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
			if hl.fg then out[i] = string.format("#%06x", hl.fg) break end
		end
	end
	return out
end

local gradient_names = vim.tbl_keys(gradients)
table.sort(gradient_names)
table.insert(gradient_names, 1, "theme")

local current_gradient -- the palette in use this session

-- Apply a palette by name ("random" picks one). Unknown names warn and
-- fall back to the colorscheme's colors.
local function set_gradient_colors(name)
	name = name or current_gradient or settings.dashboard_gradient or "random"
	if name == "random" then
		math.randomseed(vim.uv.hrtime() % 2147483647)
		name = gradient_names[math.random(#gradient_names)]
	end
	local colors = name == "theme" and theme_gradient() or gradients[name]
	if not colors then
		vim.notify(("No dashboard gradient %q; using the theme's colors"):format(name), vim.log.levels.WARN, { title = "Dashboard" })
		name, colors = "theme", theme_gradient()
	end
	current_gradient = name
	for i, color in ipairs(colors) do
		vim.api.nvim_set_hl(0, "DashboardGradient" .. i, { fg = color })
	end
end

-- `:Dashboard [name]`: the dashboard with a palette (none: the current one).
vim.api.nvim_create_user_command("Dashboard", function(opts)
	if opts.args ~= "" then set_gradient_colors(opts.args) end
	if vim.bo.filetype == "snacks_dashboard" then
		Snacks.dashboard.update()
	else
		Snacks.dashboard.open()
	end
	vim.notify("Gradient: " .. current_gradient, vim.log.levels.INFO, { title = "Dashboard" })
end, {
	nargs = "?",
	complete = function(lead) return vim.tbl_filter(function(n) return n:find(lead, 1, true) == 1 end, vim.list_extend({ "random" }, gradient_names)) end,
	desc = "Open the dashboard with a gradient",
})

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
-- Re-apply on a theme change: "theme" follows the new colors, a palette stays.
vim.api.nvim_create_autocmd("ColorScheme", { callback = function() set_gradient_colors() end })

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
	-- Guides drawn with the shared bar (utils.ui.bar: the statusline
	-- separators, the gitsigns column); the scope guide takes the mode color
	-- (SnacksIndentScope, config/colorscheme.lua).
	indent = {
		enabled = true,
		indent = { char = ui.bar, only_scope = false, only_current = false },
		scope = { enabled = true, char = ui.bar, underline = false },
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
