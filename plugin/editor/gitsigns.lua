local cfg = require("config.plugins").gitsigns or {}
if cfg.enabled == false then return end

local ui = require("utils.ui")
local sep = ui.sep -- the same " · " as the Term winbars

require("gitsigns").setup({
	-- Added / changed lines marked with the same bar as the indent guides and
	-- the statusline separators (utils.ui.bar), untracked with its dashed form.
	signs = {
		add = { text = ui.bar },
		change = { text = ui.bar },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
		untracked = { text = "┆" },
	},
	signs_staged_enable = true,
	attach_to_untracked = true,
	preview_config = { border = ui.border }, -- <leader>hp float, the shared border
	current_line_blame = false,
	current_line_blame_opts = { delay = 10 },
	current_line_blame_formatter = "   <abbrev_sha> " .. sep .. " <author>, <author_time:%R> " .. sep .. " <summary>",
	on_attach = function(bufnr)
		local gs = require("gitsigns")

		local function map(mode, l, r, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end

		map("n", "]h", function()
			if vim.wo.diff then
				vim.cmd.normal({ "]c", bang = true })
			else
				gs.nav_hunk("next")
			end
		end, { desc = "Next git hunk" })

		map("n", "[h", function()
			if vim.wo.diff then
				vim.cmd.normal({ "[c", bang = true })
			else
				gs.nav_hunk("prev")
			end
		end, { desc = "Prev git hunk" })

		map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage hunk" })
		map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk" })
		map("v", "<leader>hs", function()
			gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "Stage hunk" })
		map("v", "<leader>hr", function()
			gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "Reset hunk" })
		map("n", "<leader>hS", gs.stage_buffer, { desc = "Stage buffer" })
		map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Undo stage hunk" })
		map("n", "<leader>hR", gs.reset_buffer, { desc = "Reset buffer" })
		map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
		map("n", "<leader>hb", function()
			gs.blame_line({ full = true })
		end, { desc = "Blame line" })
		map("n", "<leader>hd", gs.diffthis, { desc = "Diff this" })
		map("n", "<leader>hD", function()
			gs.diffthis("~")
		end, { desc = "Diff this ~" })
	end,
})
