local cfg = require("config.plugins").lualine or {}
if cfg.enabled == false then return end

-- Start from lualine's `auto` theme: it derives every color from the ACTIVE
-- colorscheme's highlight groups, so changing themes later "just works".
--
-- Transparency pass (Direction 1): keep the mode/location accent pills
-- (theme.a) solid as anchors, and blank the backgrounds of every other
-- section so the bar meshes with a transparent background. We only ever set
-- bg = "none" here -- never a literal color -- so nothing is hardcoded.
-- Branch / diff / diagnostics then render as colored TEXT (their fg is still
-- theme-derived) instead of sitting on a grey slab.
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
		component_separators = { left = "|", right = "|" },
		section_separators = { left = "", right = "" },
		globalstatus = true,
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff", "diagnostics" },
		lualine_c = {
			"filename",
			{
				"aerial",
				sep = " > ",
				colored = true,
			},
		},
		lualine_x = { "encoding", "fileformat", "filetype" },
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
	tabline = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {
			{
				"buffers",
				show_filename_only = true,
				show_modified_status = true,
				mode = 0,
				symbols = {
					modified = " ●",
					alternate_file = "",
				},
			},
		},
		lualine_x = {},
		lualine_y = {},
		lualine_z = {},
	},
})
