local cfg = require("config.plugins").minifiles or {}
if cfg.enabled == false then return end

-- mini.files' defaults (h/l to move, q to close, = to synchronize, ...) with
-- a preview column and wider panes. Set up before the first frame: with
-- `use_as_default_explorer` it is what opens a directory given on the
-- command line.
require("mini.files").setup({
	windows = {
		preview = true,
		width_nofocus = 20,
		width_preview = 100,
	},
})

vim.api.nvim_create_autocmd("User", {
	pattern = "MiniFilesBufferCreate",
	callback = function(args)
		vim.keymap.set("n", "<CR>", "l", { buffer = args.data.buf_id, remap = true })
	end,
})

-- At the current file; an unnamed buffer (the dashboard, a scratch buffer)
-- opens the working directory, as mini.files does for an empty path. A
-- terminal (named Term <n>, which mini.files would reject as "not a valid
-- path"), a quickfix or location list, or any other buffer whose name is
-- not a path gets a warning instead.
vim.keymap.set("n", "<leader>e", function()
	local name = vim.api.nvim_buf_get_name(0)
	local bt = vim.bo.buftype
	if bt == "terminal" or bt == "quickfix" or (name ~= "" and not vim.uv.fs_stat(name)) then
		vim.notify("No file in this window (<leader>E opens the working directory)", vim.log.levels.WARN, { title = "Explorer" })
		return
	end
	require("mini.files").open(name, true)
end, { desc = "Explorer (file directory)" })

vim.keymap.set("n", "<leader>E", function()
	require("mini.files").open(vim.uv.cwd(), true)
end, { desc = "Explorer (cwd)" })
