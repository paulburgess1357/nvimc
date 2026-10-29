local cfg = require("config.plugins").minifiles or {}
if cfg.enabled == false then return end

require("mini.files").setup({
	content = {
		filter = nil,
		sort = nil,
	},
	mappings = {
		close = "q",
		go_in = "l",
		go_out = "h",
		go_in_plus = "L",
		mark_goto = "'",
		mark_set = "m",
		reset = "<BS>",
		reveal_cwd = "@",
		show_help = "g?",
		synchronize = "=",
		trim_left = "<",
		trim_right = ">",
	},
	options = {
		permanent_delete = true,
		use_as_default_explorer = true,
	},
	windows = {
		max_number = math.huge,
		preview = true,
		width_focus = 50,
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
-- terminal (named Term<n>, which mini.files would reject as "not a valid
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
