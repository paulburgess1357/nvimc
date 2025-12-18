-- Incline.nvim: Floating statuslines for each window showing filename.
-- Lightweight alternative to winbar that only takes up the space it needs.
local cfg = require("config.plugins").incline or {}
return {
  "b0o/incline.nvim",
  enabled = cfg.enabled ~= false,
  branch = cfg.branch,
  event = "VeryLazy",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    window = {
      padding = 0,
      margin = { horizontal = 0, vertical = 0 },
      placement = { horizontal = "right", vertical = "top" },
      zindex = 50,
    },
    hide = {
      cursorline = true,
      focused_win = false,
      only_win = false,
    },
    render = function(props)
      local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
      if filename == "" then
        filename = "[No Name]"
      end

      local ft_icon, ft_color = require("nvim-web-devicons").get_icon_color(filename)
      local modified = vim.bo[props.buf].modified

      return {
        { " " },
        ft_icon and { ft_icon, " ", guifg = ft_color } or "",
        { filename, gui = modified and "bold,italic" or "bold" },
        modified and { " ", "", guifg = "#e0af68" } or "",
        { " " },
      }
    end,
  },
}
