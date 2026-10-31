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

-- Tab pages show only when there is more than one (see lualine_x).
local function many_tabs()
	return #vim.api.nvim_list_tabpages() > 1
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
			-- The branch icon in the mode color (LualineModeAccent, colorscheme.lua),
			-- like the filetype icon on the right; the diff and diagnostics icons
			-- keep their meaning colors.
			{ "branch", icon = { "\u{F062C}", color = "LualineModeAccent" } }, -- md-source_branch
			{ "diff", symbols = { added = "\u{F0415} ", modified = "\u{F03EB} ", removed = "\u{F0374} " } }, -- md-plus md-pencil md-minus
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
		-- Filetype as two parts so only the icon takes the mode color: the icon
		-- (devicons' glyph, its own color dropped), then the name. After it,
		-- only with two or more tab pages, the tabs (utils.tabs): a tab icon in
		-- the mode color, then each tab's number with its name ("2 (build)"),
		-- the current one in the mode color and bold like the active winbar
		-- (LualineBufActive), the others in WinBarNC grey like the inactive
		-- ones. Vim's own tabline stays off ('showtabline', config/options.lua).
		lualine_x = {
			{ "filetype", icon_only = true, colored = false, color = "LualineModeAccent", separator = "", padding = { left = 1, right = 0 } },
			-- The name keeps its separator: the bar before the tabs. lualine
			-- drops it when the name is the last thing in the section.
			{ "filetype", icons_enabled = false, padding = { left = 1, right = 1 } },
			{
				function() return "\u{F04DD}" end, -- md-tab
				-- The mode color read from its group rather than named: a group
				-- name as `color` makes lualine drop the separator before it.
				color = function()
					local hl = vim.api.nvim_get_hl(0, { name = "LualineModeAccent", link = false })
					return hl.fg and { fg = string.format("#%06x", hl.fg) } or {}
				end,
				cond = many_tabs,
				separator = "",
				padding = { left = 1, right = 0 },
			},
			{
				"tabs",
				mode = 1, -- the label from fmt alone
				fmt = function(_, tab) return require("utils.tabs").short_label(tab.tabnr) end,
				show_modified_status = false,
				tabs_color = { active = "LualineBufActive", inactive = "WinBarNC" },
				component_separators = { left = "", right = "" }, -- none between the tabs
				padding = { left = 1, right = 0 },
				cond = many_tabs,
			},
		},
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
})
