local M = {}

-- Universal intuitive window resizing function
M.intuitive_resize = function(direction, amount)
  -- Check if we have multiple windows
  if vim.fn.winnr("$") == 1 then
    vim.notify("Cannot resize - only one window open", vim.log.levels.INFO)
    return
  end

  -- Get the current window
  local current_win = vim.api.nvim_get_current_win()

  -- Helper to get term codes
  local function get_term_codes(key)
    return vim.api.nvim_replace_termcodes(key, true, false, true)
  end

  -- Check if a neighbor exists
  local function has_neighbor(dir)
    return vim.fn.winnr(dir) ~= vim.fn.winnr()
  end

  -- Perform resize based on direction
  if direction == "left" then
    if has_neighbor("h") then
      vim.cmd("normal! " .. get_term_codes("<C-w>h"))
      vim.cmd("vertical resize -" .. amount)
      vim.cmd("normal! " .. get_term_codes("<C-w>l"))
    elseif has_neighbor("l") then
      vim.cmd("vertical resize -" .. amount)
    end
  elseif direction == "right" then
    if has_neighbor("l") then
      vim.cmd("vertical resize +" .. amount)
    elseif has_neighbor("h") then
      vim.cmd("normal! " .. get_term_codes("<C-w>h"))
      vim.cmd("vertical resize +" .. amount)
      vim.cmd("normal! " .. get_term_codes("<C-w>l"))
    end
  elseif direction == "up" then
    if has_neighbor("k") then
      vim.cmd("normal! " .. get_term_codes("<C-w>k"))
      vim.cmd("resize -" .. amount)
      vim.cmd("normal! " .. get_term_codes("<C-w>j"))
    elseif has_neighbor("j") then
      vim.cmd("resize -" .. amount)
    end
  elseif direction == "down" then
    if has_neighbor("j") then
      vim.cmd("resize +" .. amount)
    elseif has_neighbor("k") then
      vim.cmd("normal! " .. get_term_codes("<C-w>k"))
      vim.cmd("resize +" .. amount)
      vim.cmd("normal! " .. get_term_codes("<C-w>j"))
    end
  end

  -- Ensure we return to the original window
  if vim.api.nvim_win_is_valid(current_win) then
    vim.api.nvim_set_current_win(current_win)
  end
end

-- Helper functions for specific directions
for _, dir in ipairs({ "left", "right", "up", "down" }) do
  M["resize_" .. dir] = function(amount)
    M.intuitive_resize(dir, amount or 2)
  end
end

return M
