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
})

-- Mode-colored accents: the current line number, the snacks indent scope
-- guide and the current entry in winbars / the buffer peek popup
-- (LualineBufActive, used by utils.winbar, utils.terms, utils.buftabs) take
-- the same theme.a color as the mode pill at the bottom left (green in
-- normal, blue in insert, ...), so they all agree on what mode you are in.
-- Uses lualine's own mode -> theme-section mapping; modes the theme doesn't
-- define (terminal, command) fall back to normal, as lualine does.
local function mode_accents()
	local section = require("lualine.highlight").get_mode_suffix():sub(2)
	local a = (custom_theme[section] or custom_theme.normal or {}).a
	if not (a and a.bg) then return end
	vim.api.nvim_set_hl(0, "CursorLineNr", { fg = a.bg, bold = true })
	vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = a.bg })
	vim.api.nvim_set_hl(0, "LualineBufActive", { fg = a.bg, bold = true })
end
vim.api.nvim_create_autocmd({ "ModeChanged", "ColorScheme" }, {
	group = vim.api.nvim_create_augroup("mode_accents", { clear = true }),
	callback = mode_accents,
})
mode_accents()
