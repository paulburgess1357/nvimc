local plugins = require("config.plugins")
local cfg = plugins.rainbowdelimiters or {}
local settings = plugins.settings or {}
if cfg.enabled == false then return end

-- Not above settings.treesitter_max_kb, the limit treesitter itself stops
-- at (plugin/coding/treesitter.lua): on attach the global strategy works
-- out every delimiter in the file, which froze the editor for seconds on a
-- file of 60k lines.
local function size_ok(bufnr)
	local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
	return not (ok and stats and stats.size > (settings.treesitter_max_kb or 100) * 1024)
end

-- And attached once the file is on screen, not at its FileType event: that
-- same work takes some 45 ms for a thousand lines of Lua, which held every
-- file back by that much before it appeared, and in a session restore ran
-- for every tab's files at once. The FileType event only marks the buffer
-- pending; it is attached a tick later if it is in a window of the current
-- tab, else when its window or tab is next entered. A buffer disabled by
-- hand (:RainbowDelimiters disable) is never pending, so it stays off.
local function attach_pending(bufnr)
	if vim.api.nvim_buf_is_valid(bufnr) and vim.b[bufnr].rainbow_pending then
		vim.b[bufnr].rainbow_pending = nil
		require("rainbow-delimiters").enable(bufnr)
	end
end

local function attach_visible()
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		attach_pending(vim.api.nvim_win_get_buf(win))
	end
end

-- Scheduled, not run in the event: BufWinEnter fires inside :edit, before
-- the file has been drawn.
vim.api.nvim_create_autocmd({ "BufWinEnter", "TabEnter" }, {
	group = vim.api.nvim_create_augroup("rainbow_visible", { clear = true }),
	callback = function() vim.schedule(attach_visible) end,
})

require("rainbow-delimiters.setup").setup({
	condition = function(bufnr)
		if not size_ok(bufnr) then return false end
		-- Already attached (the file was reloaded): the plugin re-attaches as always.
		if require("rainbow-delimiters").is_enabled(bufnr) then return true end
		vim.b[bufnr].rainbow_pending = true
		vim.schedule(attach_visible)
		return false
	end,
	strategy = {
		[""] = "rainbow-delimiters.strategy.global",
		vim = "rainbow-delimiters.strategy.local",
	},
	query = {
		[""] = "rainbow-delimiters",
		lua = "rainbow-blocks",
	},
	priority = {
		[""] = 110,
		lua = 210,
	},
	highlight = {
		"RainbowDelimiterRed",
		"RainbowDelimiterYellow",
		"RainbowDelimiterBlue",
		"RainbowDelimiterOrange",
		"RainbowDelimiterGreen",
		"RainbowDelimiterViolet",
		"RainbowDelimiterCyan",
	},
})
