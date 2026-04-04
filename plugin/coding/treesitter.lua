local plugins = require("config.plugins")
local cfg = plugins.treesitter or {}
local settings = plugins.settings or {}
if cfg.enabled == false then return end

require("nvim-treesitter").install({
	"c", "cpp", "lua", "vim", "vimdoc", "python", "bash",
	"markdown", "markdown_inline", "ruby", "json", "yaml",
	"toml", "dockerfile", "regex",
})

vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		local max_filesize = (settings.treesitter_max_kb or 100) * 1024
		local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
		if ok and stats and stats.size > max_filesize then
			return
		end
		pcall(vim.treesitter.start, args.buf)
		vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
})
