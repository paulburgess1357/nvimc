local cfg = require("config.plugins").fzf or {}
if cfg.enabled == false then return end

local fzf = require("fzf-lua")
local actions = require("fzf-lua.actions")
-- Directory-scoped pickers take their root from utils.search_root (cwd, or
-- the current file's directory when the <leader><leader>. toggle is on).
local root = require("utils.search_root")

fzf.setup({
	"default-title",
	fzf_colors = true,
	-- `true` as the first element inherits fzf-lua's defaults; without it the
	-- table replaces them wholesale (losing alt-a, alt-q, F4, hide, etc.).
	keymap = {
		fzf = {
			true,
			["ctrl-j"] = "down",
			["ctrl-k"] = "up",
			["ctrl-a"] = "toggle-all", -- mark every line in the filtered list
		},
		builtin = {
			true,
			["<C-d>"] = "preview-page-down",
			["<C-u>"] = "preview-page-up",
			["<C-e>"] = "preview-down",
			["<C-y>"] = "preview-up",
			["<C-z>"] = "hide", -- hide picker; `:FzfLua unhide` / <leader><cr> restores it
		},
	},
	winopts = {
		height = 0.85,
		width = 0.80,
		preview = {
			default = "builtin",
			border = "border",
			wrap = "nowrap",
			hidden = "nohidden",
			vertical = "down:45%",
			horizontal = "right:60%",
			layout = "flex",
			flip_columns = 120,
		},
	},
	files = {
		cwd_prompt = false,
	},
	grep = {
		rg_glob = true,
		rg_opts = "--column --line-number --no-heading --color=always --smart-case --fixed-strings",
	},
	lsp = {
		async_or_timeout = 5000,
		includeDeclaration = false,
	},
	actions = {
		files = {
			true,
			["default"] = actions.file_edit,
			["ctrl-s"] = actions.file_split,
			["ctrl-v"] = actions.file_vsplit,
			["ctrl-t"] = actions.file_tabedit,
			-- Marked lines -> quickfix. Nothing marked -> the whole filtered list.
			["ctrl-q"] = {
				fn = actions.file_sel_to_qf,
				prefix = 'transform([ "$FZF_SELECT_COUNT" -eq 0 ] && echo select-all)',
			},
		},
	},
})

fzf.register_ui_select()

-- User commands
local cmd = vim.api.nvim_create_user_command
cmd("Symbols", fzf.lsp_document_symbols, { desc = "Document symbols" })
cmd("SymbolsAll", function() fzf.lsp_live_workspace_symbols(root.opts("Workspace Symbols", { cwd_only = true })) end, { desc = "Workspace symbols (live)" })
cmd("Marks", fzf.marks, { desc = "Marks" })
cmd("Files", function() fzf.files(root.opts("Files")) end, { desc = "Find files" })
cmd("Buffers", fzf.buffers, { desc = "Buffers" })
cmd("Rg", function() fzf.grep(root.opts("Grep", { search = "" })) end, { desc = "Grep" })
cmd("Grep", function() fzf.grep(root.opts("Grep", { search = "" })) end, { desc = "Grep" })
cmd("Help", fzf.help_tags, { desc = "Help tags" })
cmd("Commands", fzf.commands, { desc = "Commands" })
cmd("Keymaps", fzf.keymaps, { desc = "Keymaps" })

-- Find
vim.keymap.set("n", "<leader>ff", function() fzf.files(root.opts("Files")) end, { desc = "Files" })
vim.keymap.set("n", "<leader>fr", "<cmd>FzfLua oldfiles<cr>", { desc = "Recent files" })
vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers<cr>", { desc = "Buffers" })
-- Grep
vim.keymap.set("n", "<leader>sg", function() fzf.grep(root.opts("Grep", { search = "" })) end, { desc = "Grep" })
vim.keymap.set("n", "<leader>sw", function() fzf.grep_cword(root.opts("Grep word")) end, { desc = "Word under cursor" })
vim.keymap.set("n", "<leader>sW", function() fzf.grep_cWORD(root.opts("Grep WORD")) end, { desc = "WORD under cursor" })
vim.keymap.set("v", "<leader>sv", function() fzf.grep_visual(root.opts("Grep selection")) end, { desc = "Selection" })
vim.keymap.set("n", "<leader>sb", "<cmd>FzfLua grep_curbuf<cr>", { desc = "Buffer" })
-- Git
vim.keymap.set("n", "<leader>gf", "<cmd>FzfLua git_files<cr>", { desc = "Git files" })
vim.keymap.set("n", "<leader>gc", "<cmd>FzfLua git_commits<cr>", { desc = "Commits" })
vim.keymap.set("n", "<leader>gb", "<cmd>FzfLua git_branches<cr>", { desc = "Branches" })
vim.keymap.set("n", "<leader>gs", "<cmd>FzfLua git_status<cr>", { desc = "Status" })
-- LSP
vim.keymap.set("n", "<leader>ss", "<cmd>FzfLua lsp_document_symbols<cr>", { desc = "Document symbols" })
vim.keymap.set("n", "<leader>sS", "<cmd>FzfLua lsp_live_workspace_symbols<cr>", { desc = "Workspace symbols (live)" })
-- Misc
vim.keymap.set("n", "<leader>:", "<cmd>FzfLua command_history<cr>", { desc = "Command history" })
vim.keymap.set("n", "<leader>fh", "<cmd>FzfLua help_tags<cr>", { desc = "Help" })
vim.keymap.set("n", "<leader>fk", "<cmd>FzfLua keymaps<cr>", { desc = "Keymaps" })
vim.keymap.set("n", "<leader>fc", "<cmd>FzfLua colorschemes<cr>", { desc = "Colorschemes" })
vim.keymap.set("n", "<leader>fm", "<cmd>FzfLua marks<cr>", { desc = "Marks" })
vim.keymap.set("n", "<leader>fR", "<cmd>FzfLua registers<cr>", { desc = "Registers" })
vim.keymap.set("n", "<leader>fd", "<cmd>FzfLua diagnostics_document<cr>", { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>fD", "<cmd>FzfLua diagnostics_workspace<cr>", { desc = "Workspace diagnostics" })
vim.keymap.set("n", "<leader>fq", "<cmd>FzfLua quickfix<cr>", { desc = "Quickfix" })
vim.keymap.set("n", "<leader>fl", "<cmd>FzfLua loclist<cr>", { desc = "Location list" })
vim.keymap.set("n", "<leader>f/", "<cmd>FzfLua search_history<cr>", { desc = "Search history" })
-- Resume
vim.keymap.set("n", "<leader><cr>", "<cmd>FzfLua resume<cr>", { desc = "Resume last picker" })
