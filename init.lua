-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Load core configurations
require("config.options")
require("config.keymaps")

-- Load plugins
require("lazy").setup({
	{ import = "plugins.ai" },
	{ import = "plugins.coding" },
	{ import = "plugins.debug" },
	{ import = "plugins.editor" },
	{ import = "plugins.ui" },
}, {
	change_detection = {
		notify = false,
	},
})
