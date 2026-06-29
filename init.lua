vim.loader.enable()

require("config.options")
require("config.keymaps")

local plugins = require("config.plugins")
local gh = function(x) return "https://github.com/" .. x end

-----------------------------------------------------------
-- PackChanged hooks (must be before vim.pack.add)
-----------------------------------------------------------
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		if name == "nvim-treesitter" and (kind == "install" or kind == "update") then
			if not ev.data.active then
				vim.cmd.packadd("nvim-treesitter")
			end
			vim.cmd("TSUpdate")
		end
	end,
})

-----------------------------------------------------------
-- Build plugin specs
-----------------------------------------------------------
local specs = {}

local function add(key, ...)
	local cfg = plugins[key]
	if cfg and cfg.enabled == false then
		return
	end
	for _, spec in ipairs({ ... }) do
		table.insert(specs, spec)
	end
end

-- Shared dependencies
table.insert(specs, gh("nvim-tree/nvim-web-devicons"))

-- Coding
add("treesitter", { src = gh("nvim-treesitter/nvim-treesitter"), version = (plugins.treesitter or {}).branch })
add("lsp", gh("b0o/SchemaStore.nvim"), gh("mason-org/mason.nvim"), gh("neovim/nvim-lspconfig"), gh("mason-org/mason-lspconfig.nvim"))
add("blink", gh("rafamadriz/friendly-snippets"), { src = gh("saghen/blink.cmp"), version = vim.version.range("*") })
add("conform", gh("stevearc/conform.nvim"))
add("lint", gh("mfussenegger/nvim-lint"))
add("pairs", gh("nvim-mini/mini.pairs"))
add("increname", gh("smjonas/inc-rename.nvim"))

-- Editor
add("fzf", gh("ibhagwan/fzf-lua"))
add("gitsigns", gh("lewis6991/gitsigns.nvim"))
add("illuminate", gh("RRethy/vim-illuminate"))
add("minifiles", gh("nvim-mini/mini.files"))
add("rendermarkdown", gh("MeanderingProgrammer/render-markdown.nvim"))
add("marks", gh("chentoast/marks.nvim"))
add("todocomments", gh("nvim-lua/plenary.nvim"), gh("folke/todo-comments.nvim"))
add("spider", gh("chrisgrieser/nvim-spider"))

-- UI: colorscheme (only the active theme is installed)
-- To add a theme: add its repo here, then add a setup branch in
-- lua/config/colorscheme.lua and set `theme` in lua/config/plugins.lua.
local theme = (plugins.colorscheme or {}).theme or "onedark"
local colorscheme_specs = {
	onedark = gh("navarasu/onedark.nvim"),
}
add("colorscheme", colorscheme_specs[theme])

add("lualine", gh("nvim-lualine/lualine.nvim"))
add("whichkey", gh("folke/which-key.nvim"))
add("snacks", gh("folke/snacks.nvim"))
add("noice", gh("MunifTanjim/nui.nvim"), gh("rcarriga/nvim-notify"), gh("folke/noice.nvim"))
add("aerial", gh("stevearc/aerial.nvim"))
add("rainbowdelimiters", gh("HiPhish/rainbow-delimiters.nvim"))

-- Debug
add("dap", gh("mfussenegger/nvim-dap"), gh("nvim-neotest/nvim-nio"), gh("rcarriga/nvim-dap-ui"), gh("theHamsta/nvim-dap-virtual-text"), gh("Weissle/persistent-breakpoints.nvim"))

-----------------------------------------------------------
-- Install and load all plugins
-----------------------------------------------------------
if #specs > 0 then
	vim.pack.add(specs)
end

require("config.colorscheme")
