local cfg = require("config.plugins").leetneo or {}
if cfg.enabled == false then return end

local cmds = { "LC", "LCPull", "LCCopy", "LCRecent", "LCKeywords", "LCFold" }

local function load_and_run(cmd_name, args)
	for _, c in ipairs(cmds) do
		pcall(vim.api.nvim_del_user_command, c)
	end
	vim.cmd.packadd("LeetNeoCode")
	require("LeetNeoCode").setup({
		cache_dir = vim.fn.expand("~/.cache/nvim/LeetNeoCode"),
		default_language = "cpp",
		code_only = true,
		enable_images = false,
		smart_copy = true,
		cache_expiry_days = 13,
		fold_marker_start = "▼",
		fold_marker_end = "▲",
		recent_solutions_count = 30,
	})
	vim.cmd(cmd_name .. " " .. args)
end

for _, cmd in ipairs(cmds) do
	vim.api.nvim_create_user_command(cmd, function(a)
		load_and_run(cmd, a.args or "")
	end, { nargs = "*" })
end

-- Setup on a new machine:
--   git clone git@github.com:paulburgess1357/LeetNeoCode.git ~/Repos/LeetNeoCode
--   mkdir -p ~/.config/nvim-custom/pack/local/opt
--   ln -s ~/Repos/LeetNeoCode ~/.config/nvim-custom/pack/local/opt/LeetNeoCode
