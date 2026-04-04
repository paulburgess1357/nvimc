local cfg = require("config.plugins").conform or {}
if cfg.enabled == false then return end

require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "ruff_format" },
		cpp = { "clang-format" },
		c = { "clang-format" },
		rust = { "rustfmt" },
		sh = { "shfmt" },
		bash = { "shfmt" },
		markdown = { "prettier" },
		json = { "prettier" },
		yaml = { "prettier" },
		toml = { "taplo" },
	},
	format_on_save = function()
		if vim.g.disable_autoformat then
			return
		end
		return {
			timeout_ms = 500,
			lsp_format = "fallback",
		}
	end,
})

vim.keymap.set("n", "<leader>cf", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer" })
