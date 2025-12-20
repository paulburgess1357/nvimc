-- LSP: Language Server Protocol support for code intelligence.
-- Provides auto-completion, go-to-definition, diagnostics, and code actions.
local plugins = require("config.plugins")
local lsp_cfg = plugins.lsp or {}
local mason_cfg = plugins.mason or {}
return {
	-- SchemaStore: JSON/YAML schema catalog for validation
	{
		"b0o/SchemaStore.nvim",
		enabled = lsp_cfg.enabled ~= false,
		lazy = true,
	},

	-- Mason: Package manager for LSP servers, linters, and formatters
	{
		"mason-org/mason.nvim",
		enabled = mason_cfg.enabled ~= false,
		branch = mason_cfg.branch,
		opts = {},
	},

	-- LSP configurations and keybindings
	{
		"neovim/nvim-lspconfig",
		enabled = lsp_cfg.enabled ~= false,
		branch = lsp_cfg.branch,
		dependencies = {
			"mason-org/mason.nvim",
			"mason-org/mason-lspconfig.nvim",
		},
		config = function()
			-- Use bright diagnostic colors for virtual text (no background)
			local function set_virtual_text_hl()
				for _, level in ipairs({ "Error", "Warn", "Info", "Hint" }) do
					local diag_fg = vim.api.nvim_get_hl(0, { name = "Diagnostic" .. level }).fg
					vim.api.nvim_set_hl(0, "DiagnosticVirtualText" .. level, { fg = diag_fg })
				end
			end
			set_virtual_text_hl()
			vim.api.nvim_create_autocmd("ColorScheme", { callback = set_virtual_text_hl })

			-- Diagnostic display configuration
			vim.diagnostic.config({
				underline = true,
				update_in_insert = false,
				virtual_text = false,
				float = {
					source = true,
					border = "rounded",
					focusable = false,
				},
				severity_sort = true,
			})

			-- Match diagnostic float background to editor Normal background
			local function sync_float_bg()
				local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
				if normal_bg then
					local float_hl = vim.api.nvim_get_hl(0, { name = "NormalFloat" })
					float_hl.bg = normal_bg
					vim.api.nvim_set_hl(0, "NormalFloat", float_hl)

					local border_hl = vim.api.nvim_get_hl(0, { name = "FloatBorder" })
					border_hl.bg = normal_bg
					vim.api.nvim_set_hl(0, "FloatBorder", border_hl)
				end
			end
			sync_float_bg()
			vim.api.nvim_create_autocmd("ColorScheme", { callback = sync_float_bg })

			-- Global diagnostic keymap (doesn't need LSP attached)
			vim.keymap.set("n", "gl", function()
				-- Get diagnostics for current line and find most severe
				local diagnostics = vim.diagnostic.get(0, { lnum = vim.api.nvim_win_get_cursor(0)[1] - 1 })
				local severity_hl = {
					[vim.diagnostic.severity.ERROR] = "DiagnosticError",
					[vim.diagnostic.severity.WARN] = "DiagnosticWarn",
					[vim.diagnostic.severity.INFO] = "DiagnosticInfo",
					[vim.diagnostic.severity.HINT] = "DiagnosticHint",
				}
				local highest_severity = vim.diagnostic.severity.HINT
				for _, d in ipairs(diagnostics) do
					if d.severity < highest_severity then
						highest_severity = d.severity
					end
				end
				-- Set border color from theme's diagnostic highlight
				local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
				local diag_fg = vim.api.nvim_get_hl(0, { name = severity_hl[highest_severity] }).fg
				vim.api.nvim_set_hl(0, "FloatBorder", { fg = diag_fg, bg = normal_bg })
				vim.diagnostic.open_float({ scope = "line", border = "rounded", source = true, focusable = false })
			end, { desc = "Line Diagnostics" })

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					-- Navigation (using fzf-lua)
					map("gd", function()
						require("fzf-lua").lsp_definitions()
					end, "Go to definition")
					map("gD", vim.lsp.buf.declaration, "Go to declaration")
					map("gr", function()
						require("fzf-lua").lsp_references()
					end, "Go to references")
					map("gI", function()
						require("fzf-lua").lsp_implementations()
					end, "Go to implementation")
					map("gy", function()
						require("fzf-lua").lsp_typedefs()
					end, "Go to type definition")

					-- Documentation
					map("K", vim.lsp.buf.hover, "Hover documentation")
					map("gK", vim.lsp.buf.signature_help, "Signature help")

					-- Code actions (using fzf-lua)
					map("<leader>ca", function()
						require("fzf-lua").lsp_code_actions()
					end, "Code action")
					-- Rename is handled by inc-rename.nvim

					-- Diagnostics (using fzf-lua)
					map("<leader>cd", function()
						require("fzf-lua").diagnostics_document()
					end, "Document diagnostics")
					map("[d", function()
						vim.diagnostic.jump({ count = -1, float = true })
					end, "Previous diagnostic")
					map("]d", function()
						vim.diagnostic.jump({ count = 1, float = true })
					end, "Next diagnostic")

					-- Format is handled by conform.nvim
				end,
			})

			-- Custom clangd configuration using vim.lsp.config (Neovim 0.11+)
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
				root_markers = {
					".clangd",
					".clang-tidy",
					".clang-format",
					"compile_commands.json",
					"compile_flags.txt",
					".git",
				},
			}

			-- JSON LSP with SchemaStore
			vim.lsp.config.jsonls = {
				settings = {
					json = {
						schemas = require("schemastore").json.schemas(),
						validate = { enable = true },
					},
				},
			}

			-- YAML LSP with SchemaStore
			vim.lsp.config.yamlls = {
				settings = {
					yaml = {
						schemaStore = { enable = false, url = "" },
						schemas = require("schemastore").yaml.schemas(),
						validate = true,
					},
				},
			}
		end,
	},

	-- Mason-LSPconfig: Bridge between Mason and lspconfig
	{
		"mason-org/mason-lspconfig.nvim",
		enabled = mason_cfg.enabled ~= false,
		branch = mason_cfg.branch,
		dependencies = {
			"mason-org/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		opts = {
			ensure_installed = {
				-- Languages
				"lua_ls",
				"clangd",
				"pyright",
				"ruby_lsp",
				"bashls",
				-- Config/Data
				"jsonls",
				"yamlls",
				"taplo",
				-- Containers
				"dockerls",
				"docker_compose_language_service",
			},
			automatic_enable = true,
		},
	},
}
