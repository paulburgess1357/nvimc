local plugins = require("config.plugins")
local cfg = plugins.whichkey or {}
local ui = require("utils.ui")
local border = ui.border
if cfg.enabled == false then return end

local wk = require("which-key")
wk.setup({
	preset = "helix",
	delay = 200,
	win = {
		border = border,
		padding = ui.padding, -- one column, like every float
		title_pos = ui.title_pos, -- group name on the left, like every float's title
	},
	icons = {
		-- No icon per mapping: which-key's rules draw them from several Nerd
		-- Font sets. Only the group icons stated in `spec` below show.
		rules = false,
		-- Between a key and its label, and in the cmdline's key trail: the
		-- same chevron as the breadcrumb in the statusline.
		separator = ui.crumb,
		breadcrumb = ui.crumb,
		-- which-key's glyphs for special keys are Material except the arrows.
		keys = {
			Up = "\u{F005D} ", -- md-arrow_up
			Down = "\u{F0045} ", -- md-arrow_down
			Left = "\u{F004D} ", -- md-arrow_left
			Right = "\u{F0054} ", -- md-arrow_right
		},
	},
	-- Group icons: Material, like every other pictogram (see utils.ui).
	spec = {
		{ "<leader>b", group = "Buffer", icon = "\u{F0214}" }, -- md-file
		{ "<leader>c", group = "Code", icon = "\u{F0174}" }, -- md-code_tags
		{ "<leader>d", group = "Debug", icon = "\u{F00E4}" }, -- md-bug
		{ "<leader>f", group = "Find", icon = "\u{F021E}" }, -- md-file_find
		{ "<leader>g", group = "Git", icon = "\u{F02A2}" }, -- md-git
		{ "<leader>h", group = "Hunk", icon = "\u{F062C}" }, -- md-source_branch
		{ "<leader>s", group = "Search", icon = "\u{F13B8}" }, -- md-text_search
		{ "<leader>u", group = "UI", icon = "\u{F0675}" }, -- md-application_cog
		{ "<leader><leader>", group = "Custom", icon = "\u{F0633}" }, -- md-apple_keyboard_command
	},
})

-- Snacks toggles
local Snacks = require("snacks")
local static_desc = { enabled = "", disabled = "" }

local wrap_toggle = Snacks.toggle.option("wrap", { name = "Wrap", wk_desc = static_desc })
wrap_toggle:map("<leader>uw")
wrap_toggle:map("<leader><leader>w")
Snacks.toggle.option("relativenumber", { name = "Relative number", wk_desc = static_desc }):map("<leader>ul")
Snacks.toggle.option("spell", { name = "Spell", wk_desc = static_desc }):map("<leader>us")

Snacks.toggle({
	name = "Diagnostic signs",
	wk_desc = static_desc,
	get = function()
		return vim.diagnostic.config().signs ~= false
	end,
	set = function(state)
		vim.diagnostic.config({ signs = state })
	end,
}):map("<leader><leader>s")

Snacks.toggle({
	name = "Virtual text",
	wk_desc = static_desc,
	get = function()
		return vim.diagnostic.config().virtual_text ~= false
	end,
	set = function(state)
		vim.diagnostic.config({
			virtual_text = state and {
				spacing = 4,
				source = "if_many",
				-- One icon per line, not one per diagnostic: the level's glyph (the
				-- same as the sign in the gutter) in front of the first message,
				-- which is the most severe one since severity_sort is on.
				prefix = function(diag, i)
					if i ~= 1 then return "" end
					local icons = ui.diagnostics
					return ({ icons.error, icons.warn, icons.info, icons.hint })[diag.severity] or ""
				end,
			} or false,
		})
	end,
}):map("<leader><leader>v")

Snacks.toggle({
	name = "Format on save",
	wk_desc = static_desc,
	get = function()
		return not vim.g.disable_autoformat
	end,
	set = function(state)
		vim.g.disable_autoformat = not state
	end,
}):map("<leader><leader>a")

local smart_wrap_copy = require("utils.smart_wrap_copy")
Snacks.toggle({
	name = "Smart wrap copy",
	wk_desc = static_desc,
	get = smart_wrap_copy.is_enabled,
	set = smart_wrap_copy.set_enabled,
}):map("<leader><leader>t")

-- Sticky context (treesitter-context): enclosing scopes pinned at the top.
Snacks.toggle({
	name = "Context",
	wk_desc = static_desc,
	get = function() return require("treesitter-context").enabled() end,
	set = function(state) require("treesitter-context")[state and "enable" or "disable"]() end,
}):map("<leader><leader>c")

Snacks.toggle({
	name = "Git blame",
	wk_desc = static_desc,
	get = function()
		return require("gitsigns.config").config.current_line_blame
	end,
	set = function(state)
		require("gitsigns").toggle_current_line_blame(state)
	end,
}):map("<leader><leader>b")

-- Ctrl/Alt+hjkl inside Term windows: on, they move/resize Neovim windows;
-- off, they reach the program running in the terminal (nested vim, TUIs).
local terms = require("utils.terms")
Snacks.toggle({
	name = "Terminal window keys",
	wk_desc = static_desc,
	get = function()
		return terms.window_keys
	end,
	set = function(state)
		terms.window_keys = state
	end,
}):map("<leader><leader>k")

-- Buffer peek popup (utils.buftabs): always show parent/file instead of
-- only when two files share a name.
local buftabs = require("utils.buftabs")
Snacks.toggle({
	name = "Buffer parent dir",
	wk_desc = static_desc,
	get = function()
		return buftabs.show_parent
	end,
	set = function(state)
		buftabs.show_parent = state
	end,
}):map("<leader><leader>p")

-- Search root for every directory-scoped fzf picker (see utils.search_root):
-- cycles working directory -> project root -> file directory. Session-only.
local search_root = require("utils.search_root")
vim.keymap.set("n", "<leader><leader>.", search_root.cycle, { desc = "Cycle search root (cwd / project / file dir)" })

-- Zoom: the current window's buffer in a full-size float (file or terminal).
-- The layout underneath is untouched, so toggling off restores it exactly.
Snacks.toggle({
	name = "Zoom",
	wk_desc = static_desc,
	get = function()
		return (Snacks.zen.win ~= nil and Snacks.zen.win:valid()) or false
	end,
	set = function(state)
		if state then
			Snacks.zen.zoom()
		elseif Snacks.zen.win then
			Snacks.zen.win:close()
		end
	end,
}):map("<leader><leader>z")

-- Custom menu keymaps
vim.keymap.set("n", "<leader><leader>f", function()
	require("fzf-lua").files(search_root.opts("Files"))
end, { desc = "Find files (root)" })

vim.keymap.set("n", "<leader><leader>g", function()
	require("fzf-lua").grep(search_root.opts("Grep", { search = "" }))
end, { desc = "Grep (root)" })

vim.keymap.set("n", "<leader><leader>h", function()
	require("fzf-lua").files({ cwd = vim.uv.os_homedir() })
end, { desc = "Find files (home)" })

vim.keymap.set("n", "<leader><leader>j", function()
	require("fzf-lua").grep({ search = "", cwd = vim.uv.os_homedir() })
end, { desc = "Grep (home)" })

vim.keymap.set("n", "<leader><leader>r", function()
	require("fzf-lua").oldfiles()
end, { desc = "Recent files" })

vim.keymap.set("n", "<leader><leader>m", function()
	require("fzf-lua").marks()
end, { desc = "Marks" })

vim.keymap.set("n", "<leader><leader>l", function()
	require("fzf-lua").lsp_live_workspace_symbols()
end, { desc = "Symbols (workspace)" })

vim.keymap.set("n", "<leader>?", function()
	require("which-key").show({ global = false })
end, { desc = "Buffer keymaps" })
