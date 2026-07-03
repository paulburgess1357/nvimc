-- Smart Wrap Copy
--
-- Terminal buffers store every screen row as its own buffer line, so a
-- logical line longer than the terminal width soft-wraps into several buffer
-- lines. Yanking that text captures hard newlines that were never in the
-- output (https://github.com/neovim/neovim/issues/30117), which breaks
-- pasting commands into another terminal or document.
--
-- Neovim exposes no wrap-continuation info, so this uses the reliable
-- heuristic: the terminal PTY is exactly as wide as the window's text area,
-- and a wrapped row always fills it completely. After each yank in a
-- terminal buffer, any yanked line whose display width equals the terminal
-- width is joined with the line that follows it.
--
-- Known limitation (inherent to the heuristic): a real output line that is
-- exactly terminal-width, followed by another line, gets joined too.
--
-- Toggle: <leader><leader>w (registered in plugin/ui/whichkey.lua).

local M = {}

M.enabled = true

function M.is_enabled()
	return M.enabled
end

function M.set_enabled(state)
	M.enabled = state
end

-- Join wrapped continuations: a line that completely fills the terminal
-- width continues onto the next buffer line.
local function unwrap(lines, width)
	local out, acc = {}, nil
	for _, line in ipairs(lines) do
		acc = (acc or "") .. line
		if vim.fn.strdisplaywidth(line) ~= width then
			table.insert(out, acc)
			acc = nil
		end
	end
	if acc then
		table.insert(out, acc)
	end
	return out
end

function M.setup()
	vim.api.nvim_create_autocmd("TextYankPost", {
		group = vim.api.nvim_create_augroup("smart_wrap_copy", { clear = true }),
		callback = function()
			if not M.enabled or vim.bo.buftype ~= "terminal" then
				return
			end
			local ev = vim.v.event
			-- Only plain yanks; blockwise selections are deliberate shapes.
			if ev.operator ~= "y" or ev.regtype:sub(1, 1) == "\22" then
				return
			end
			local lines = ev.regcontents
			if #lines < 2 then
				return
			end
			-- The PTY is sized to the window's text area, so that is the
			-- wrap width (0.11+ reflows scrollback on resize, so it also
			-- holds for old output after resizing).
			local win = vim.api.nvim_get_current_win()
			local width = vim.api.nvim_win_get_width(win) - vim.fn.getwininfo(win)[1].textoff
			local joined = unwrap(lines, width)
			if #joined == #lines then
				return
			end
			local regname = ev.regname == "" and '"' or ev.regname
			vim.fn.setreg(regname, joined, ev.regtype)
			-- With clipboard=unnamedplus an unnamed yank also lands in "+",
			-- and setreg('"') does not sync it back -- update it explicitly.
			-- pcall: never let a missing clipboard provider break the yank.
			if ev.regname == "" and vim.o.clipboard:match("unnamedplus") then
				pcall(vim.fn.setreg, "+", joined, ev.regtype)
			end
		end,
	})
end

return M
