local cfg = require("config.plugins").fzf or {}
if cfg.enabled == false then return end

local fzf = require("fzf-lua")
local actions = require("fzf-lua.actions")

fzf.setup({
	"default-title",
	keymap = {
		fzf = {
			["ctrl-j"] = "down",
			["ctrl-k"] = "up",
		},
		builtin = {
			["<C-d>"] = "preview-page-down",
			["<C-u>"] = "preview-page-up",
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
			["default"] = actions.file_edit,
			["ctrl-s"] = actions.file_split,
			["ctrl-v"] = actions.file_vsplit,
			["ctrl-t"] = actions.file_tabedit,
		},
	},
})

fzf.register_ui_select()

-- User commands
local cmd = vim.api.nvim_create_user_command
cmd("Symbols", fzf.lsp_document_symbols, { desc = "Document symbols" })
cmd("Marks", fzf.marks, { desc = "Marks" })
cmd("Files", fzf.files, { desc = "Find files" })
cmd("Buffers", fzf.buffers, { desc = "Buffers" })
cmd("Rg", fzf.live_grep, { desc = "Live grep" })
cmd("Grep", fzf.live_grep, { desc = "Live grep" })
cmd("Help", fzf.help_tags, { desc = "Help tags" })
cmd("Commands", fzf.commands, { desc = "Commands" })
cmd("Keymaps", fzf.keymaps, { desc = "Keymaps" })

-- Find
vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<cr>", { desc = "Files" })
vim.keymap.set("n", "<leader>fr", "<cmd>FzfLua oldfiles<cr>", { desc = "Recent files" })
vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers<cr>", { desc = "Buffers" })
-- Grep
vim.keymap.set("n", "<leader>sg", "<cmd>FzfLua live_grep<cr>", { desc = "Grep" })
vim.keymap.set("n", "<leader>sw", "<cmd>FzfLua grep_cword<cr>", { desc = "Word under cursor" })
vim.keymap.set("n", "<leader>sW", "<cmd>FzfLua grep_cWORD<cr>", { desc = "WORD under cursor" })
vim.keymap.set("v", "<leader>sv", "<cmd>FzfLua grep_visual<cr>", { desc = "Selection" })
vim.keymap.set("n", "<leader>sb", "<cmd>FzfLua lgrep_curbuf<cr>", { desc = "Buffer" })
-- Git
vim.keymap.set("n", "<leader>gf", "<cmd>FzfLua git_files<cr>", { desc = "Git files" })
vim.keymap.set("n", "<leader>gc", "<cmd>FzfLua git_commits<cr>", { desc = "Commits" })
vim.keymap.set("n", "<leader>gb", "<cmd>FzfLua git_branches<cr>", { desc = "Branches" })
vim.keymap.set("n", "<leader>gs", "<cmd>FzfLua git_status<cr>", { desc = "Status" })
-- LSP
vim.keymap.set("n", "<leader>ss", "<cmd>FzfLua lsp_document_symbols<cr>", { desc = "Document symbols" })
vim.keymap.set("n", "<leader>sS", "<cmd>FzfLua lsp_workspace_symbols<cr>", { desc = "Workspace symbols" })
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
