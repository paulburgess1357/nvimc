-- CopilotChat.nvim: Chat interface for GitHub Copilot.
-- Provides interactive AI chat for code explanations, refactoring, and more.
local cfg = require("config.plugins").copilotchat or {}

local function setup_chat_buf(buf)
	vim.bo[buf].buflisted = false
	for _, key in ipairs({ "<S-h>", "<S-l>", "<leader>-", "<leader>|" }) do
		vim.keymap.set("n", key, "<nop>", { buffer = buf })
	end
end

return {
	"CopilotC-Nvim/CopilotChat.nvim",
	enabled = cfg.enabled ~= false,
	branch = cfg.branch,
	dependencies = { "github/copilot.vim" },
	cmd = "CopilotChat",
	opts = {},
	config = function(_, opts)
		require("CopilotChat").setup(opts)
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "copilot-chat",
			callback = function(ev)
				setup_chat_buf(ev.buf)
			end,
		})
	end,
}
