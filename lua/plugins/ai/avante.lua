-- avante.nvim: AI-powered coding assistant with agentic capabilities
-- https://github.com/yetone/avante.nvim
local cfg = require("config.plugins").avante or {}

local function setup_commands()
	local cmd = vim.api.nvim_create_user_command
	cmd("Chat", "AvanteToggle", { desc = "Toggle AI chat" })
	cmd("ChatNew", "AvanteChatNew", { desc = "New AI chat" })
	cmd("ChatHistory", "AvanteHistory", { desc = "Browse chat history" })
	cmd("ChatCommands", function()
		local ref = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h") .. "/AvanteReference.md"
		vim.cmd("edit " .. ref)
	end, { desc = "Open avante reference" })
end

return {
	"yetone/avante.nvim",
	enabled = cfg.enabled ~= false,
	branch = cfg.branch,
	build = "make",

	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"nvim-tree/nvim-web-devicons",
		"MeanderingProgrammer/render-markdown.nvim",
		"HakonHarnes/img-clip.nvim",
	},

	cmd = {
		"AvanteToggle",
		"AvanteChatNew",
		"AvanteHistory",
		"Chat",
		"ChatNew",
		"ChatHistory",
		"ChatCommands",
	},

	config = function(_, opts)
		require("avante").setup(opts)
		setup_commands()
	end,

	opts = {
		provider = "cursor",
		mode = "agentic",
		mappings = {
			select_model = "<Nop>",
		},
		acp_providers = {
			cursor = {
				command = os.getenv("HOME") .. "/.local/bin/agent",
				args = { "acp" },
				auth_method = "cursor_login",
				env = {
					HOME = os.getenv("HOME"),
					PATH = os.getenv("PATH"),
				},
			},
		},
	},
}
