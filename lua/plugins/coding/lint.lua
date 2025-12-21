-- nvim-lint: Asynchronous linters that LSP doesn't cover.
-- Install: cppcheck (system), shellcheck/hadolint (Mason)
local cfg = require("config.plugins").lint or {}

-- Cppcheck cache (avoids recalculating path on every lint)
local cppcheck_cache = {}
local function get_cppcheck_cache_dir()
	local cwd = vim.fn.getcwd()
	if cppcheck_cache[cwd] then
		return cppcheck_cache[cwd]
	end
	local name = vim.fn.fnamemodify(cwd, ":t")
	local hash = vim.fn.sha256(cwd):sub(1, 8)
	local dir = vim.fn.expand("~/.cache/nvim-cppcheck/" .. name .. "-" .. hash)
	vim.fn.mkdir(dir, "p")
	cppcheck_cache[cwd] = dir
	return dir
end

return {
	"mfussenegger/nvim-lint",
	enabled = cfg.enabled ~= false,
	event = { "BufReadPre", "BufNewFile" },
	keys = {
		{
			"<leader>cl",
			function()
				require("lint").try_lint()
			end,
			desc = "Lint file",
		},
	},
	config = function()
		local lint = require("lint")

		-- Only linters that LSP doesn't provide
		lint.linters_by_ft = {
			c = { "cppcheck" },
			cpp = { "cppcheck" },
			sh = { "shellcheck" },
			bash = { "shellcheck" },
			dockerfile = { "hadolint" },
		}

		-- Cppcheck configuration
		lint.linters.cppcheck.args = {
			"--enable=all",
			"--inconclusive",
			"--check-level=exhaustive",
			function()
				return vim.bo.filetype == "cpp" and "--language=c++" or "--language=c"
			end,
			"--std=c++17",
			"--suppress=missingIncludeSystem",
			"--inline-suppr",
			"--quiet",
			"--template={file}:{line}:{column}: [{id}] {severity}: {message}",
			function()
				return "--cppcheck-build-dir=" .. get_cppcheck_cache_dir()
			end,
		}

		-- Auto-lint on save and buffer enter
		vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
			group = vim.api.nvim_create_augroup("lint", { clear = true }),
			callback = function()
				if vim.bo.modifiable then
					lint.try_lint()
				end
			end,
		})
	end,
}
