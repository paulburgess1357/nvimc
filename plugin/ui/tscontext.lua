local plugins = require("config.plugins")
local cfg = plugins.tscontext or {}
local settings = plugins.settings or {}
if cfg.enabled == false then return end

-- Sticky context: while the cursor is inside a function, class, loop, etc.,
-- its opening line stays pinned at the top of the window. Toggle:
-- <leader><leader>c (plugin/ui/whichkey.lua).
require("treesitter-context").setup({
	max_lines = settings.context_max_lines or 3, -- at most this many pinned lines
	multiline_threshold = 1, -- a context that spans several lines shows only its first
	trim_scope = "outer", -- past max_lines, drop the outermost scopes first
	mode = "cursor",
	separator = "─", -- TreesitterContextSeparator, set in config/colorscheme.lua
})
