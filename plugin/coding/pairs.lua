local cfg = require("config.plugins").pairs or {}
if cfg.enabled == false then return end

-- mini.pairs' defaults as they are: brackets and quotes auto-closed in insert
-- mode, no pair after a backslash, no `'` after a letter. Set up once the
-- first frame is drawn (utils.startup): the mappings are insert-mode only.
require("utils.startup").after(function()
	require("mini.pairs").setup()
end)
