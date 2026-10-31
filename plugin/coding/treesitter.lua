local plugins = require("config.plugins")
local cfg = plugins.treesitter or {}
local settings = plugins.settings or {}
if cfg.enabled == false then return end

-- Parsers missing from this list are installed in the background. The
-- check reads the parser directory, so it waits for the first frame
-- (utils.startup); the installed parsers work without it.
require("utils.startup").after(function()
	require("nvim-treesitter").install({
		"c", "cpp", "lua", "vim", "vimdoc", "python", "bash",
		"markdown", "markdown_inline", "ruby", "json", "yaml",
		"toml", "dockerfile", "regex",
	})
end)

vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		local max_filesize = (settings.treesitter_max_kb or 100) * 1024
		local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
		if ok and stats and stats.size > max_filesize then
			-- Neovim starts treesitter itself for some filetypes (lua, c, ...),
			-- so for a file over the limit it is stopped, not merely not started.
			-- Folds come from treesitter too (utils.folds) and would parse the
			-- whole file on their own: manual folding here, as snacks' bigfile
			-- does above its own limit.
			pcall(vim.treesitter.stop, args.buf)
			vim.opt_local.foldmethod = "manual"
			return
		end
		pcall(vim.treesitter.start, args.buf)
		vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
})
