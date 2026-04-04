local plugins = require("config.plugins")
local lsp_cfg = plugins.lsp or {}
local mason_cfg = plugins.mason or {}
if lsp_cfg.enabled == false then return end

-----------------------------------------------------------
-- Server Configurations
-----------------------------------------------------------
vim.lsp.config.clangd = {
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--header-insertion=never",
		"--completion-style=detailed",
		"--function-arg-placeholders=true",
		"--enable-config",
		"--limit-references=0",
		"--limit-results=0",
	},
	filetypes = {
		"c", "cpp", "objc", "objcpp", "cuda", "proto",
		"cppm", "hpp", "tpp", "ipp", "cxx", "cc", "hxx", "hh", "h",
	},
	root_markers = { ".clangd", ".clang-tidy", "compile_commands.json", ".git" },
}

vim.lsp.config.rust_analyzer = {
	settings = {
		["rust-analyzer"] = {
			check = { command = "clippy" },
			cargo = { allFeatures = true },
			procMacro = { enable = true },
		},
	},
}

vim.lsp.config.gopls = {
	settings = {
		gopls = {
			analyses = { unusedparams = true, shadow = true },
			staticcheck = true,
			gofumpt = true,
		},
	},
}

vim.lsp.config.lua_ls = {
	settings = {
		Lua = {
			diagnostics = { globals = { "vim", "Snacks" } },
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
		},
	},
}

vim.lsp.config.jsonls = {
	settings = {
		json = {
			schemas = require("schemastore").json.schemas(),
			validate = { enable = true },
		},
	},
}

vim.lsp.config.yamlls = {
	settings = {
		yaml = {
			schemaStore = { enable = false, url = "" },
			schemas = require("schemastore").yaml.schemas(),
			validate = true,
		},
	},
}

vim.lsp.config.tailwindcss = {
	filetypes = {
		"html", "css", "scss", "javascript", "javascriptreact",
		"typescript", "typescriptreact", "vue", "svelte",
	},
}

-----------------------------------------------------------
-- Diagnostics & Highlights
-----------------------------------------------------------
vim.diagnostic.config({
	underline = true,
	update_in_insert = false,
	virtual_text = false,
	float = { source = true, border = "rounded", focusable = false },
	severity_sort = true,
})

local function sync_highlights()
	local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
	if normal_bg then
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = normal_bg })
		vim.api.nvim_set_hl(0, "FloatBorder", { bg = normal_bg })
	end
	for _, level in ipairs({ "Error", "Warn", "Info", "Hint" }) do
		local fg = vim.api.nvim_get_hl(0, { name = "Diagnostic" .. level }).fg
		vim.api.nvim_set_hl(0, "DiagnosticVirtualText" .. level, { fg = fg })
	end
end
sync_highlights()
vim.api.nvim_create_autocmd("ColorScheme", { callback = sync_highlights })

-----------------------------------------------------------
-- Keymaps
-----------------------------------------------------------
vim.keymap.set("n", "gl", function()
	local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
	local diags = vim.diagnostic.get(0, { lnum = lnum })
	local severity_hl = {
		[vim.diagnostic.severity.ERROR] = "DiagnosticError",
		[vim.diagnostic.severity.WARN] = "DiagnosticWarn",
		[vim.diagnostic.severity.INFO] = "DiagnosticInfo",
		[vim.diagnostic.severity.HINT] = "DiagnosticHint",
	}
	local highest = vim.diagnostic.severity.HINT
	for _, d in ipairs(diags) do
		if d.severity < highest then
			highest = d.severity
		end
	end
	local bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
	local fg = vim.api.nvim_get_hl(0, { name = severity_hl[highest] }).fg
	vim.api.nvim_set_hl(0, "FloatBorder", { fg = fg, bg = bg })
	vim.diagnostic.open_float({ scope = "line", border = "rounded" })
end, { desc = "Line diagnostics" })

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
	callback = function(event)
		local map = function(keys, func, desc)
			vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end
		local fzf = require("fzf-lua")

		map("gd", fzf.lsp_definitions, "Definition")
		map("gD", vim.lsp.buf.declaration, "Declaration")
		map("gr", fzf.lsp_references, "References")
		map("gI", fzf.lsp_implementations, "Implementation")
		map("gy", fzf.lsp_typedefs, "Type definition")
		map("K", vim.lsp.buf.hover, "Hover")
		map("gK", vim.lsp.buf.signature_help, "Signature help")
		map("<leader>ca", fzf.lsp_code_actions, "Code action")
		map("<leader>cd", fzf.diagnostics_document, "Document diagnostics")
		map("[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev diagnostic")
		map("]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic")
	end,
})

-----------------------------------------------------------
-- Mason
-----------------------------------------------------------
if mason_cfg.enabled ~= false then
	require("mason").setup()
	require("mason-lspconfig").setup({
		ensure_installed = {
			"lua_ls", "clangd", "pyright", "rust_analyzer", "gopls",
			"ts_ls", "ruby_lsp", "bashls", "html", "cssls", "tailwindcss",
			"jsonls", "yamlls", "taplo", "dockerls", "docker_compose_language_service",
		},
		automatic_enable = true,
	})
end
