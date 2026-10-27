local cfg = require("config.plugins").lualine or {}
if cfg.enabled == false then return end

local ui = require("utils.ui")

-- Start from lualine's `auto` theme: it derives every color from the ACTIVE
-- colorscheme's highlight groups, so changing themes later "just works".
--
-- Transparency pass (Direction 1): keep the mode/location accent pills
-- (theme.a) solid as anchors, and blank the backgrounds of every other
-- section so the bar meshes with a transparent background. We only ever set
-- bg = "none" here -- never a literal color -- so nothing is hardcoded.
-- Branch / diff / diagnostics then render as colored TEXT (their fg is still
-- theme-derived) instead of sitting on a grey slab.
--
-- The same theme.a colors drive the mode accents (line number, scope guide,
-- active winbar): see mode_accents in config/colorscheme.lua.
local custom_theme = require("lualine.themes.auto")
for _, mode in pairs(custom_theme) do
	for _, key in ipairs({ "b", "c" }) do -- b -> {b,y}, c -> {c,x}
		if mode[key] then
			mode[key].bg = "none"
		end
	end
end

require("lualine").setup({
	options = {
		theme = custom_theme,
		icons_enabled = true,
		component_separators = { left = ui.bar, right = ui.bar },
		section_separators = { left = "", right = "" },
		globalstatus = true,
	},
	-- No filename: every file window names itself in its winbar
	-- (utils.winbar), and the terminals in theirs. No encoding / fileformat:
	-- always utf-8 / unix here.
	sections = {
		lualine_a = { "mode" },
		lualine_b = {
			{ "branch", icon = "\u{F062C}" }, -- md-source_branch
			"diff",
			{
				"diagnostics",
				-- The same glyphs as the gutter signs and the notifier.
				symbols = {
					error = ui.diagnostics.error .. " ",
					warn = ui.diagnostics.warn .. " ",
					info = ui.diagnostics.info .. " ",
					hint = ui.diagnostics.hint .. " ",
				},
			},
		},
		lualine_c = {
			{
				"aerial",
				sep = " " .. ui.crumb .. " ",
				colored = true,
			},
		},
		lualine_x = { "filetype" },
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
})
