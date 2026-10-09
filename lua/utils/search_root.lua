local M = {}

-- Root directory for fzf-lua's directory-scoped pickers (files, grep,
-- cwd-only workspace symbols). Three modes, cycled by <leader><leader>.
-- (plugin/ui/whichkey.lua), each narrower than the last:
--
--   cwd      Neovim's working directory (default, as always)
--   project  the project the current file belongs to: the nearest ancestor
--            holding a .git, else one holding another project marker, else
--            the file's own directory
--   file     the directory of the file in the current window
--
-- "project" and "file" fall back to cwd when the window holds no real file
-- (dashboard, terminal, mini.files, ...). Session-only: starts at cwd.
-- The <leader><leader>h/j home pickers ignore all of this.

M.modes = {
	{ id = "cwd", label = "Working directory" },
	{ id = "project", label = "Project root" },
	{ id = "file", label = "File directory" },
}
M.mode = 1

-- Checked only when no .git is found above the file, so a repo always wins
-- over a nested package inside it.
local PROJECT_MARKERS = {
	"pyproject.toml", "setup.py", "requirements.txt",
	"package.json", "Cargo.toml", "go.mod",
	"compile_commands.json", "CMakeLists.txt", ".clangd", "Makefile",
}

local function current_file()
	if vim.bo.buftype ~= "" then return nil end
	local name = vim.api.nvim_buf_get_name(0)
	return name ~= "" and vim.fn.fnamemodify(name, ":p") or nil
end

function M.dir()
	local id = M.modes[M.mode].id
	local file = id ~= "cwd" and current_file() or nil
	if not file then return vim.fn.getcwd() end
	local file_dir = vim.fn.fnamemodify(file, ":h")
	if id == "file" then return file_dir end
	return vim.fs.root(file, ".git") or vim.fs.root(file, PROJECT_MARKERS) or file_dir
end

function M.label()
	return M.modes[M.mode].label
end

-- Next mode, with a notification naming it and the directory it resolves to
-- for the current window.
function M.cycle()
	M.mode = M.mode % #M.modes + 1
	vim.notify(("Search root: %s\n%s"):format(M.label(), vim.fn.fnamemodify(M.dir(), ":~")), vim.log.levels.INFO)
end

-- Picker opts for `label`: the root as cwd, and a title that names it so the
-- active directory is always visible. `extra` is merged on top.
function M.opts(label, extra)
	local dir = M.dir()
	local opts = { cwd = dir, winopts = { title = " " .. label .. " · " .. vim.fn.fnamemodify(dir, ":~") .. " " } }
	return extra and vim.tbl_deep_extend("force", opts, extra) or opts
end

return M
