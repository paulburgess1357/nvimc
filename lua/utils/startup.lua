-- Work that can wait until the first frame is on screen.
--
-- Every plugin/*.lua file is sourced before Neovim draws anything, so a
-- setup() the first frame does not need (the completion engine, the
-- statusline, mason's registry, a picker's defaults) only delays it. M.after
-- queues such work and runs it from a vim.schedule() off VimEnter: that
-- lands after the first redraw (the dashboard is on screen by then) but
-- before any key typed so far is handled, so nothing can see a plugin
-- unconfigured. Called after VimEnter (a plugin file loaded by hand) it
-- runs on the next tick. One failing setup is reported and the rest still
-- run, as separate plugin files would.
--
-- Not for anything a file named on the command line needs before VimEnter,
-- which is read before then: autocmds on BufReadPost / FileType
-- (treesitter, gitsigns, lint, persistent-breakpoints) and vim.lsp.enable()
-- stay in the plugin files.

local M = {}

local queue = {}

function M.after(fn)
	if vim.v.vim_did_enter == 1 then
		vim.schedule(fn)
		return
	end
	queue[#queue + 1] = fn
end

vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		vim.schedule(function()
			local fns = queue
			queue = {}
			for _, fn in ipairs(fns) do
				local ok, err = pcall(fn)
				if not ok then vim.notify(tostring(err), vim.log.levels.ERROR, { title = "Startup" }) end
			end
		end)
	end,
})

return M
