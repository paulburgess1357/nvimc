local keymap = vim.keymap

-- Clear search highlights
keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Window navigation
keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Window resizing (intuitive - Alt+hjkl)
local resize = require("utils.resize")
keymap.set("n", "<A-h>", resize.resize_left, { desc = "Resize window left" })
keymap.set("n", "<A-l>", resize.resize_right, { desc = "Resize window right" })
keymap.set("n", "<A-k>", resize.resize_up, { desc = "Resize window up" })
keymap.set("n", "<A-j>", resize.resize_down, { desc = "Resize window down" })

-- Window splitting
keymap.set("n", "<leader>-", "<cmd>split<CR>", { desc = "Split horizontally" })
keymap.set("n", "<leader>|", "<cmd>vsplit<CR>", { desc = "Split vertically" })
keymap.set("n", "<leader>wd", "<cmd>close<CR>", { desc = "Delete window" })

-- Buffer navigation
keymap.set("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
keymap.set("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })

-- Buffer management
keymap.set("n", "<leader>bd", function()
	Snacks.bufdelete()
end, { desc = "Delete buffer" })
keymap.set("n", "<leader>bD", function()
	Snacks.bufdelete({ force = true })
end, { desc = "Delete buffer (force)" })

-- Move lines up/down
keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Better indenting
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")

-- Keep cursor centered when scrolling
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")

-- Save file
keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })

-- Quit
keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })

-- Comment (visual mode only)
keymap.set("v", "<leader>c", "gc", { remap = true, desc = "Comment" })

-- Terminal
keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Force LSP to index all project files (fixes clangd missing references)
vim.api.nvim_create_user_command("LspIndexAll", function()
	-- Get filetypes from current buffer's LSP clients
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	if #clients == 0 then
		vim.notify("No LSP client attached", vim.log.levels.WARN)
		return
	end

	local filetypes = {}
	for _, client in ipairs(clients) do
		local fts = client.config.filetypes or {}
		for _, ft in ipairs(fts) do
			filetypes[ft] = true
		end
	end

	local client_names = vim.tbl_map(function(c) return c.name end, clients)
	local lsp_name = table.concat(client_names, ", ")

	-- Find all files and check if they match LSP filetypes
	local root = vim.fn.getcwd()
	local all_files = vim.fn.globpath(root, "**/*", false, true)
	local total = #all_files
	local count = 0
	local processed = 0

	vim.notify(string.format("Indexing files for %s...", lsp_name), vim.log.levels.INFO)

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
			vim.notify(string.format("[%s] Indexing: %d%% (%d files loaded)", lsp_name, pct, count), vim.log.levels.INFO)
			vim.schedule(function()
				process_batch(end_idx + 1)
			end)
		else
			vim.notify(string.format("[%s] Indexing complete: %d files loaded", lsp_name, count), vim.log.levels.INFO)
		end
	end

	process_batch(1)
end, { desc = "Force LSP to index all project files" })
