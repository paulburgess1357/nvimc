local cfg = require("config.plugins").whichkey or {}
if cfg.enabled == false then return end

local wk = require("which-key")
wk.setup({
	preset = "helix",
	delay = 200,
	win = {
		border = "rounded",
		padding = { 1, 2 },
	},
	spec = {
		{ "<leader>b", group = "Buffer", icon = "" },
		{ "<leader>c", group = "Code", icon = "" },
		{ "<leader>d", group = "Debug", icon = "" },
		{ "<leader>f", group = "Find", icon = "" },
		{ "<leader>g", group = "Git", icon = "" },
		{ "<leader>h", group = "Hunk", icon = "" },
		{ "<leader>s", group = "Search", icon = "" },
		{ "<leader>u", group = "UI", icon = "" },
		{ "<leader><leader>", group = "Custom", icon = "" },
	},
})

-- Snacks toggles
local Snacks = require("snacks")
local static_desc = { enabled = "", disabled = "" }

Snacks.toggle.option("wrap", { name = "Wrap", wk_desc = static_desc }):map("<leader>uw")
Snacks.toggle.option("relativenumber", { name = "Relative Number", wk_desc = static_desc }):map("<leader>ul")
Snacks.toggle.option("spell", { name = "Spell", wk_desc = static_desc }):map("<leader>us")

Snacks.toggle({
	name = "Diagnostic Signs",
	wk_desc = static_desc,
	get = function()
		return vim.diagnostic.config().signs ~= false
	end,
	set = function(state)
		vim.diagnostic.config({ signs = state })
	end,
}):map("<leader><leader>s")

Snacks.toggle({
	name = "Virtual Text",
	wk_desc = static_desc,
	get = function()
		return vim.diagnostic.config().virtual_text ~= false
	end,
	set = function(state)
		vim.diagnostic.config({
			virtual_text = state and {
				spacing = 4,
				source = "if_many",
				prefix = "",
			} or false,
		})
	end,
}):map("<leader><leader>v")

Snacks.toggle({
	name = "Format on Save",
	wk_desc = static_desc,
	get = function()
		return not vim.g.disable_autoformat
	end,
	set = function(state)
		vim.g.disable_autoformat = not state
	end,
}):map("<leader><leader>a")

Snacks.toggle({
	name = "Git Blame",
	wk_desc = static_desc,
	get = function()
		return require("gitsigns.config").config.current_line_blame
	end,
	set = function(state)
		require("gitsigns").toggle_current_line_blame(state)
	end,
}):map("<leader><leader>b")

-- Custom menu keymaps
vim.keymap.set("n", "<leader><leader>f", function()
	require("fzf-lua").files({ cwd = vim.fn.getcwd() })
end, { desc = "Find files (cwd)" })

vim.keymap.set("n", "<leader><leader>g", function()
	require("fzf-lua").grep({ search = "", cwd = vim.fn.getcwd() })
end, { desc = "Grep (cwd)" })

vim.keymap.set("n", "<leader><leader>h", function()
	require("fzf-lua").files({ cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":h:h") })
end, { desc = "Find files (home)" })

vim.keymap.set("n", "<leader><leader>j", function()
	require("fzf-lua").grep({ search = "", cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":h:h") })
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
