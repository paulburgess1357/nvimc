local plugins = require("config.plugins")
local cfg = plugins.lint or {}
local settings = plugins.settings or {}
if cfg.enabled == false then return end

local lint = require("lint")

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

local cppcheck_linter = settings.cppcheck ~= false and { "cppcheck" } or {}
lint.linters_by_ft = {
	c = cppcheck_linter,
	cpp = cppcheck_linter,
	sh = { "shellcheck" },
	bash = { "shellcheck" },
	dockerfile = { "hadolint" },
}

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

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
	group = vim.api.nvim_create_augroup("lint", { clear = true }),
	callback = function()
		if vim.bo.modifiable and vim.bo.buftype == "" then
			lint.try_lint()
		end
	end,
})

vim.keymap.set("n", "<leader>cl", function()
	lint.try_lint()
end, { desc = "Lint file" })
