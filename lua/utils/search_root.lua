local M = {}

-- Root directory for fzf-lua's directory-scoped pickers (files, grep,
-- cwd-only workspace symbols). Off (default): Neovim's cwd, as always. On:
-- the directory of the file in the current window, falling back to cwd when
-- the window holds no real file (dashboard, terminal, mini.files, ...).
-- Session-only. Toggled by "Search From File Dir" on <leader><leader>.
-- (plugin/ui/whichkey.lua); the <leader><leader>h/j home pickers ignore it.
M.file_dir = false

function M.dir()
	if M.file_dir and vim.bo.buftype == "" then
		local name = vim.api.nvim_buf_get_name(0)
		if name ~= "" then return vim.fn.fnamemodify(name, ":p:h") end
	end
	return vim.fn.getcwd()
end

-- Picker opts for `label`: the root as cwd, and a title that names it so the
-- active directory is always visible. `extra` is merged on top.
function M.opts(label, extra)
	local dir = M.dir()
	local opts = { cwd = dir, winopts = { title = " " .. label .. " · " .. vim.fn.fnamemodify(dir, ":~") .. " " } }
	return extra and vim.tbl_deep_extend("force", opts, extra) or opts
end

return M
