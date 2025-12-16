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
keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })
keymap.set("n", "<leader>bD", "<cmd>bdelete!<CR>", { desc = "Delete buffer (force)" })

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

-- Terminal
keymap.set("n", "<C-/>", function()
  require("snacks").terminal(nil, { cwd = vim.fn.getcwd() })
end, { desc = "Terminal (cwd)" })
keymap.set("n", "<C-_>", function()
  require("snacks").terminal(nil, { cwd = vim.fn.getcwd() })
end, { desc = "Terminal (cwd)" })
keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
