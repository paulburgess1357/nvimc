local plugins = require("config.plugins")
local border = require("utils.ui").border
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

-- SchemaStore's catalog is a large table (several ms to load); it is read
-- when the server starts, not at startup, by filling in the settings just
-- before the initialize request.
vim.lsp.config.jsonls = {
	settings = {
		json = {
			validate = { enable = true },
		},
	},
	before_init = function(_, config)
		config.settings.json.schemas = require("schemastore").json.schemas()
	end,
}

vim.lsp.config.yamlls = {
	settings = {
		yaml = {
			schemaStore = { enable = false, url = "" },
			validate = true,
		},
	},
	before_init = function(_, config)
		config.settings.yaml.schemas = require("schemastore").yaml.schemas()
	end,
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
local diag_icons = require("utils.ui").diagnostics
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
		map("<leader>cx", vim.lsp.codelens.run, "Run code lens")
	end,
})

-- Neovim's own LSP maps gra, gri, grn, grr, grt and grx begin with gr, so gr
-- (references, above) would wait 'timeoutlen' for a third key before every
-- picker. Their actions are all mapped above (<leader>ca, gI, <leader>cr,
-- gr, gy, <leader>cx), so the defaults go.
for _, lhs in ipairs({ "gra", "gri", "grn", "grr", "grt", "grx" }) do
	for _, mode in ipairs({ "n", "x" }) do
		pcall(vim.keymap.del, mode, lhs)
	end
end

-----------------------------------------------------------
-- Servers and Mason
-----------------------------------------------------------
-- The servers mason keeps installed, enabled here outright. vim.lsp.enable()
-- costs nothing (a FileType autocmd that looks each config up on first use)
-- and must run before VimEnter: a file named on the command line gets its
-- FileType event before then. A server in the list that is not installed
-- yet is skipped when a buffer of its type opens (noted in :LspLog only).
-- mason-lspconfig used to do this enabling, at the price of loading its
-- registry (20-30 ms) before the first frame.
local servers = {
	"lua_ls", "clangd", "pyright", "rust_analyzer", "gopls",
	"ts_ls", "bashls", "html", "cssls", "tailwindcss",
	"jsonls", "yamlls", "taplo", "dockerls", "docker_compose_language_service",
}

if mason_cfg.enabled ~= false then
	-- Mason's bin directory first in PATH, where mason.setup() would put it,
	-- so the servers are found when the first buffer opens.
	vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH
end
vim.lsp.enable(servers)

if mason_cfg.enabled ~= false then
	-- mason and mason-lspconfig load their package registry: for the :Mason
	-- UI, for installing what ensure_installed lacks, and for enabling any
	-- server installed by hand through :Mason. None of it is needed for the
	-- first frame, so it runs once that is drawn (utils.startup).
	require("utils.startup").after(function()
		require("mason").setup({ ui = { border = border }, PATH = "skip" })
		require("mason-lspconfig").setup({
			ensure_installed = servers,
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

		-- Resolve the enabled configs now (nvim-lspconfig's lsp/<name>.lua
		-- files, a few ms in all) rather than at the first FileType event,
		-- which otherwise does it for every enabled server before the first
		-- buffer can attach. Neovim caches a resolved config while it stays
		-- enabled; after mason-lspconfig, which enables servers of its own.
		for _, name in ipairs(servers) do
			local _ = vim.lsp.config[name]
		end
	end)
end

-- Force LSP to index all project files (fixes clangd missing references)
vim.api.nvim_create_user_command("LspIndexAll", function()
	-- Get filetypes from current buffer's LSP clients
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	if #clients == 0 then
		vim.notify("No LSP client attached", vim.log.levels.WARN, { title = "LSP" })
		return
	end

	local filetypes = {}
	for _, client in ipairs(clients) do
		local fts = client.config.filetypes or {}
		for _, ft in ipairs(fts) do
			filetypes[ft] = true
		end
	end

	-- Find all files and check if they match LSP filetypes
	local root = vim.fn.getcwd()
	local all_files = vim.fn.globpath(root, "**/*", false, true)
	local total = #all_files
	local count = 0
	local processed = 0
	local last_pct = -1

	-- Reported as LSP progress of the first client (an LspProgress event in
	-- the shape of clangd's own "indexing"), so it shows in the same
	-- bottom-right line as any server task (noice's mini view) instead of as
	-- messages, which noice would turn into notifications.
	local client_id = clients[1].id
	local function progress(value)
		vim.api.nvim_exec_autocmds("LspProgress", {
			pattern = value.kind,
			modeline = false,
			data = { client_id = client_id, params = { token = "LspIndexAll", value = value } },
		})
	end

	progress({ kind = "begin", title = "Indexing", message = total .. " files", percentage = 0 })

	local function process_batch(start_idx)
		local batch_size = 50
		local end_idx = math.min(start_idx + batch_size - 1, total)

		for i = start_idx, end_idx do
			local file = all_files[i]
			if file and vim.fn.filereadable(file) == 1 then
				local ft = vim.filetype.match({ filename = file })
				if ft and filetypes[ft] then
					local bufnr = vim.fn.bufadd(file)
					vim.fn.bufload(bufnr)
					count = count + 1
				end
			end
			processed = processed + 1
		end

		if end_idx < total then
			local pct = math.floor((processed / total) * 100)
			-- Only update the display every 10%
			if pct >= last_pct + 10 then
				last_pct = pct
				progress({ kind = "report", message = count .. " files loaded", percentage = pct })
			end
			vim.schedule(function()
				process_batch(end_idx + 1)
			end)
		else
			-- The done line reads "<check> Indexed N files <server>".
			progress({ kind = "end", title = ("Indexed %d files"):format(count) })
		end
	end

	process_batch(1)
end, { desc = "Force LSP to index all project files" })

vim.api.nvim_create_user_command("LspLog", function()
	vim.cmd.edit(vim.lsp.log.get_filename())
end, { desc = "Open LSP log file" })
