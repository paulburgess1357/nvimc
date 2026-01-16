-- Lualine.nvim: Fast and customizable statusline written in Lua.
-- Displays mode, git branch, diagnostics, and file info with minimal overhead.
local cfg = require("config.plugins").lualine or {}

-- Helper to get color from highlight group (theme-aware)
local function get_hl_fg(name)
	local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
	return hl.fg and string.format("#%06x", hl.fg) or nil
end

-- MCPHub status component (uses global variables for lazy-loading)
local mcphub_component = {
	function()
		if not vim.g.loaded_mcphub then
			return ""
		end
		local count = vim.g.mcphub_servers_count or 0
		local status = vim.g.mcphub_status or "stopped"
		local executing = vim.g.mcphub_executing
		if status == "stopped" then
			return "󰐻 -"
		end
		if executing or status == "starting" or status == "restarting" then
			local frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
			local frame = math.floor(vim.uv.now() / 100) % #frames + 1
			return "󰐻 " .. frames[frame]
		end
		return "󰐻 " .. count
	end,
	color = function()
		if not vim.g.loaded_mcphub then
			return { fg = get_hl_fg("Comment") }
		end
		local status = vim.g.mcphub_status or "stopped"
		if status == "ready" or status == "restarted" then
			return { fg = get_hl_fg("DiagnosticOk") or get_hl_fg("String") }
		elseif status == "starting" or status == "restarting" then
			return { fg = get_hl_fg("DiagnosticWarn") }
		else
			return { fg = get_hl_fg("DiagnosticError") }
		end
	end,
	cond = function()
		return vim.g.loaded_mcphub ~= nil
	end,
}

return {
	"nvim-lualine/lualine.nvim",
	enabled = cfg.enabled ~= false,
	branch = cfg.branch,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"stevearc/aerial.nvim",
		"franco-ruggeri/codecompanion-lualine.nvim",
	},
	opts = function()
		local normal_hl = vim.api.nvim_get_hl(0, { name = "Normal" })
		local normal_bg = normal_hl.bg and string.format("#%06x", normal_hl.bg) or nil
		local custom_theme = require("lualine.themes.auto")
		-- Set tabline background to match Normal
		if normal_bg then
			for _, mode in pairs(custom_theme) do
				if mode.c then
					mode.c.bg = normal_bg
				end
			end
		end
		return {
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
				lualine_x = { mcphub_component, "codecompanion", "encoding", "fileformat", "filetype" },
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
		}
	end,
}
