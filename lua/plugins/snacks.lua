-- Dashboard header color theme
local header_theme = "aurora"

local color_themes = {
  -- Gradients
  rainbow = { "#f7768e", "#ff9e64", "#e0af68", "#9ece6a", "#7dcfff", "#7aa2f7" },
  sunset = { "#f7768e", "#ff9e64", "#e0af68", "#e0af68", "#ff9e64", "#f7768e" },
  ocean = { "#7aa2f7", "#7dcfff", "#73daca", "#73daca", "#7dcfff", "#7aa2f7" },
  forest = { "#73daca", "#9ece6a", "#c3e88d", "#c3e88d", "#9ece6a", "#73daca" },
  fire = { "#f7768e", "#ff9e64", "#e0af68", "#ff9e64", "#f7768e", "#db4b4b" },
  aurora = { "#bb9af7", "#7aa2f7", "#7dcfff", "#73daca", "#9ece6a", "#e0af68" },
  synthwave = { "#ff007c", "#d121d1", "#bd93f9", "#8be9fd", "#50fa7b", "#f1fa8c" },
  miami = { "#ff79c6", "#bd93f9", "#8be9fd", "#8be9fd", "#bd93f9", "#ff79c6" },
  nord = { "#88c0d0", "#81a1c1", "#5e81ac", "#5e81ac", "#81a1c1", "#88c0d0" },
  catppuccin = { "#f5c2e7", "#cba6f7", "#89b4fa", "#94e2d5", "#a6e3a1", "#f9e2af" },
  -- Solid colors
  yellow = { "#e0af68", "#e0af68", "#e0af68", "#e0af68", "#e0af68", "#e0af68" },
  cyan = { "#7dcfff", "#7dcfff", "#7dcfff", "#7dcfff", "#7dcfff", "#7dcfff" },
  pink = { "#f7768e", "#f7768e", "#f7768e", "#f7768e", "#f7768e", "#f7768e" },
  green = { "#9ece6a", "#9ece6a", "#9ece6a", "#9ece6a", "#9ece6a", "#9ece6a" },
  blue = { "#7aa2f7", "#7aa2f7", "#7aa2f7", "#7aa2f7", "#7aa2f7", "#7aa2f7" },
  purple = { "#bb9af7", "#bb9af7", "#bb9af7", "#bb9af7", "#bb9af7", "#bb9af7" },
}

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    -- Performance optimizations for large files
    bigfile = {
      enabled = true,
      notify = true,
      size = 1.5 * 1024 * 1024, -- 1.5MB
      -- Disable features for big files
      setup = function(ctx)
        vim.cmd([[NoMatchParen]])
        vim.opt_local.swapfile = false
        vim.opt_local.foldmethod = "manual"
        vim.opt_local.undolevels = -1
        vim.opt_local.undoreload = 0
        vim.opt_local.list = false
      end,
    },

    -- Startup dashboard with gradient header
    dashboard = {
      enabled = true,
      preset = {
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
      sections = {
        -- Gradient header - each line gets its own color
        {
          text = {
            {
              "███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
              hl = "DashboardGradient1",
            },
          },
          align = "center",
          padding = 0,
        },
        {
          text = {
            {
              "████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
              hl = "DashboardGradient2",
            },
          },
          align = "center",
          padding = 0,
        },
        {
          text = {
            {
              "██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
              hl = "DashboardGradient3",
            },
          },
          align = "center",
          padding = 0,
        },
        {
          text = {
            {
              "██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
              hl = "DashboardGradient4",
            },
          },
          align = "center",
          padding = 0,
        },
        {
          text = {
            {
              "██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
              hl = "DashboardGradient5",
            },
          },
          align = "center",
          padding = 0,
        },
        {
          text = {
            {
              "╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
              hl = "DashboardGradient6",
            },
          },
          align = "center",
          padding = 1,
        },
        { section = "keys", gap = 1, padding = 1 },
      },
    },

    -- Indent guides with scope highlighting
    indent = {
      enabled = true,
      indent = {
        char = "│",
        only_scope = false,
        only_current = false,
      },
      scope = {
        enabled = true,
        char = "│",
        underline = false,
      },
      animate = {
        enabled = true,
        duration = {
          step = 20,
          total = 300,
        },
      },
    },

    -- Notification system
    notifier = {
      enabled = true,
      timeout = 3000,
      width = { min = 40, max = 0.4 },
      height = { min = 1, max = 0.6 },
      margin = { top = 0, right = 1, bottom = 0 },
      padding = true,
      sort = { "level", "added" },
      icons = {
        error = " ",
        warn = " ",
        info = " ",
        debug = " ",
        trace = " ",
      },
    },

    -- Smooth scrolling
    scroll = {
      enabled = true,
      animate = {
        duration = { step = 15, total = 250 },
        easing = "linear",
      },
    },

    -- Terminal
    terminal = {
      enabled = true,
      win = {
        style = "terminal",
      },
    },
  },
  init = function()
    local function set_gradient_colors()
      local colors = color_themes[header_theme] or color_themes.rainbow
      for i, color in ipairs(colors) do
        vim.api.nvim_set_hl(0, "DashboardGradient" .. i, { fg = color })
      end
    end

    -- Set on colorscheme change
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "*",
      callback = set_gradient_colors,
    })

    -- Set immediately
    set_gradient_colors()
  end,
  keys = {
    -- Terminal
    {
      "<C-/>",
      function()
        require("snacks").terminal(nil, { cwd = vim.fn.getcwd() })
      end,
      desc = "Terminal (cwd)",
    },
    {
      "<C-_>",
      function()
        require("snacks").terminal(nil, { cwd = vim.fn.getcwd() })
      end,
      desc = "Terminal (cwd)",
    },
    -- Notifications
    {
      "<leader>n",
      function()
        require("snacks").notifier.show_history()
      end,
      desc = "Notification History",
    },
    {
      "<leader>un",
      function()
        require("snacks").notifier.hide()
      end,
      desc = "Dismiss All Notifications",
    },
  },
}
