-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Tabs and indentation
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
-- Note: smartindent/cindent removed - treesitter and filetype indent handle this

-- Line wrapping
vim.opt.wrap = false

-- Search settings
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
-- Literal search/substitute lives in keymaps.lua (/, ? and :s prefix \V).
-- Do NOT set 'magic' off for this: plugins build patterns assuming it is
-- on (:h 'magic').

-- Appearance
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.showmode = false -- Hide native mode indicator (lualine shows it)
vim.opt.cmdheight = 0 -- Hide command line (noice handles it in a popup)
-- Float border for everything (settings.border in plugins.lua, read through
-- utils.ui). Plugins that set their own border read the same setting.
vim.opt.winborder = require("utils.ui").border
-- No tabline: file windows are named by their winbar (utils.winbar) and
-- <leader><leader>e shows the buffer tabs in a popup (utils.buftabs). lualine has no
-- tabline section, so it never turns this back on.
vim.opt.showtabline = 0
-- Whitespace you would otherwise not see, in the indent guides' grey
-- (Whitespace / NonText): trailing spaces as the usual dot, no-break spaces,
-- and the chevrons used elsewhere (the aerial breadcrumb) when a long line
-- runs off the edge of a nowrap window. Tabs render as blank so the indent
-- guides (snacks) draw over them as they do over spaces.
vim.opt.list = true
vim.opt.listchars = { tab = "  ", trail = "·", nbsp = "␣", extends = "›", precedes = "‹" }

-- Backspace
vim.opt.backspace = "indent,eol,start"

-- Clipboard
vim.opt.clipboard:append("unnamedplus")

-- Split windows
vim.opt.splitright = true
vim.opt.splitbelow = true
-- Don't re-equalize every window whenever one opens or closes: hand-resized
-- splits keep their size when a terminal, aerial, etc. comes and goes.
-- <C-w>= equalizes on demand.
-- When a window's height changes (a Term opening or closing underneath),
-- keep the text where it is on screen instead of the cursor row.
vim.opt.splitkeep = "screen"
vim.opt.equalalways = false

-- Scrolling
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
-- <C-o>/<C-i> restore the scroll position along with the cursor, so jumping
-- back shows the window as it was.
vim.opt.jumpoptions = "view"

-- Terminal history rows, per terminal buffer (default 10000). Lower keeps
-- memory down and makes width changes cheap: every terminal resize rewraps
-- the whole scrollback, and the Term system (utils.terms) resizes windows
-- whenever a right-side column opens or closes.
vim.opt.scrollback = 2000

-- Undo and backup
vim.opt.undofile = true
vim.opt.backup = false
vim.opt.swapfile = false

-- Update time
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Confirm before quitting with unsaved changes
vim.opt.confirm = true

-- Auto-reload files changed outside of Neovim
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
	command = "silent! checktime",
})

-- Reopen a file at the cursor position it was last closed with (the '"
-- mark, kept in shada), unless that is a commit message or similar where
-- starting at the top is the point.
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function(ev)
		if vim.tbl_contains({ "gitcommit", "gitrebase" }, vim.bo[ev.buf].filetype) then return end
		local line = vim.api.nvim_buf_get_mark(ev.buf, '"')[1]
		if line > 0 and line <= vim.api.nvim_buf_line_count(ev.buf) then
			pcall(vim.api.nvim_win_set_cursor, 0, { line, 0 })
		end
	end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.hl.on_yank({ higroup = "Visual", timeout = 150 })
	end,
})

-- Folds by syntax tree, with a code-highlighted fold line (utils.folds)
require("utils.folds").setup()

-- Terminal window title (kitty's title bar / tab): the working directory,
-- with ~ for home. The active file is already named by its winbar.
vim.opt.title = true
vim.opt.titlestring = "%{fnamemodify(getcwd(), ':~')}"
