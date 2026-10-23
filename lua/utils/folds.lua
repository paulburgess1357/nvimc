-- Folds by syntax tree. 'foldexpr' comes from treesitter, so zc on a
-- function, class, if block or table folds exactly that scope; files open
-- fully unfolded. A closed fold shows its first line as code (treesitter
-- highlights, not one flat Folded color) followed by a grey line count, with
-- no dash fill. Loaded from config/options.lua.

local M = {}

-- 'foldtext' callback: a list of { text, highlight } pieces for the fold's
-- first line, each piece colored by the treesitter capture under it.
function _G.fold_text()
	local lnum = vim.v.foldstart
	local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1] or ""
	local pieces = {}
	local ok, parser = pcall(vim.treesitter.get_parser, 0)
	local query = ok and parser and vim.treesitter.query.get(parser:lang(), "highlights")
	if query then
		local tree = parser:parse({ lnum - 1, lnum })[1]
		local col = 0
		local prev
		for id, node in query:iter_captures(tree:root(), 0, lnum - 1, lnum) do
			local srow, scol, erow, ecol = node:range()
			if srow == lnum - 1 and erow == lnum - 1 then
				if scol > col then pieces[#pieces + 1] = { line:sub(col + 1, scol), "Folded" } end
				local piece = { line:sub(scol + 1, ecol), "@" .. query.captures[id] }
				-- Several captures on the same range: the last (most specific) wins.
				if prev and prev[1] == scol and prev[2] == ecol then pieces[#pieces] = piece else pieces[#pieces + 1] = piece end
				prev, col = { scol, ecol }, math.max(col, ecol)
			end
		end
		if col < #line then pieces[#pieces + 1] = { line:sub(col + 1), "Folded" } end
	else
		pieces[1] = { line, "Folded" }
	end
	local tab = string.rep(" ", vim.bo.tabstop)
	for _, p in ipairs(pieces) do p[1] = p[1]:gsub("\t", tab) end
	pieces[#pieces + 1] = { " · " .. (vim.v.foldend - lnum + 1) .. " lines", "Comment" }
	return pieces
end

function M.setup()
	vim.opt.foldmethod = "expr"
	vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
	vim.opt.foldlevel = 99 -- everything open on load
	vim.opt.foldlevelstart = 99
	vim.opt.foldtext = "v:lua.fold_text()"
	vim.opt.fillchars:append({ fold = " " })
end

return M
