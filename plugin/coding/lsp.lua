local plugins = require("config.plugins")
local border = (plugins.settings or {}).border or "single"
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
	filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
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
local diag_icons = require("utils.icons").diagnostics
vim.diagnostic.config({
	underline = true,
	update_in_insert = false,
	virtual_text = false,
	-- Gutter signs: the same glyphs as the notifications and statusline.
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = diag_icons.error,
			[vim.diagnostic.severity.WARN] = diag_icons.warn,
			[vim.diagnostic.severity.INFO] = diag_icons.info,
			[vim.diagnostic.severity.HINT] = diag_icons.hint,
		},
	},
	float = { source = true, border = border, focusable = false },
	severity_sort = true,
})

-- Float colors come from the colorscheme (config/colorscheme.lua); only the
-- virtual text groups are derived here.
local function sync_highlights()
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
	-- Border in the severity color, on this float only (not the global
	-- FloatBorder group, which every other float shares).
	local _, win = vim.diagnostic.open_float({ scope = "line", border = border })
	if win then vim.wo[win].winhighlight = "FloatBorder:" .. severity_hl[highest] end
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
		map("gR", fzf.lsp_finder, "Finder (all locations)")
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
			"ts_ls", "bashls", "html", "cssls", "tailwindcss",
			"jsonls", "yamlls", "taplo", "dockerls", "docker_compose_language_service",
		},
		automatic_enable = true,
	})

	-- Non-LSP tools used by conform/nvim-lint. mason-lspconfig only installs
	-- language servers, so ensure these separately via the registry.
	local ensure_tools = { "shfmt", "hadolint" }
	local registry = require("mason-registry")
	local function install_missing_tools()
		for _, name in ipairs(ensure_tools) do
			local ok, pkg = pcall(registry.get_package, name)
			if ok and not pkg:is_installed() then
				pkg:install()
			end
		end
	end
	registry.refresh(vim.schedule_wrap(install_missing_tools))
end

vim.api.nvim_create_user_command("LspLog", function()
	vim.cmd.edit(vim.lsp.log.get_filename())
end, { desc = "Open LSP log file" })
