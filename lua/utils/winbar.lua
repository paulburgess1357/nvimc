-- Filename winbar for file windows, laid out like the Term<n> titles in
-- utils.terms (" <icon> <name> ●") and colored like the buffer tabline. With several file splits open, every
-- pane says which file it shows, the same way every terminal says which
-- slot it is. Only ordinary file buffers get one; terminals keep their own
-- winbar, and pickers, the dashboard, floats, etc. get none.

local M = {}

function _G.file_winbar()
	local name = vim.fn.expand("%:t")
	if name == "" then return "" end
	local icon, hl = "", nil
	local ok, devicons = pcall(require, "nvim-web-devicons")
	if ok then
		icon, hl = devicons.get_icon(name, vim.fn.expand("%:e"), { default = true })
	end
	local parts = { " " }
	if icon and icon ~= "" then parts[#parts + 1] = (hl and ("%#" .. hl .. "#") or "") .. icon .. "%* " end
	-- Same colors as the tabline: mode color on the active window (group set
	-- in plugin/ui/lualine.lua), inactive windows in the usual WinBarNC grey.
	local active = tonumber(vim.g.actual_curwin) == vim.api.nvim_get_current_win()
	parts[#parts + 1] = (active and "%#LualineBufActive#" or "%#WinBarNC#") .. name:gsub("%%", "%%%%") .. "%*"
	if vim.bo.modified then parts[#parts + 1] = " ●" end
	return table.concat(parts)
end

local function wants_winbar(win)
	if vim.api.nvim_win_get_config(win).relative ~= "" then return false end
	local buf = vim.api.nvim_win_get_buf(win)
	return vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= ""
end

function M.setup()
	vim.api.nvim_create_autocmd({ "BufWinEnter", "BufFilePost", "TermOpen" }, {
		group = vim.api.nvim_create_augroup("file_winbar", { clear = true }),
		callback = function()
			local win = vim.api.nvim_get_current_win()
			if wants_winbar(win) then
				vim.wo[win].winbar = "%{%v:lua.file_winbar()%}"
			elseif vim.wo[win].winbar:find("file_winbar", 1, true) then
				vim.wo[win].winbar = ""
			end
		end,
	})
end

return M
