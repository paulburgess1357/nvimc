-- Which-key.nvim: Displays available keybindings in a popup as you type.
-- Helps discover and remember keymaps with visual hints and groupings.
local cfg = require("config.plugins").whichkey or {}
return {
  "folke/which-key.nvim",
  enabled = cfg.enabled ~= false,
  branch = cfg.branch,
  event = "VeryLazy",
  opts = {
    preset = "helix",
    delay = 200,
    win = {
      border = "rounded",
      padding = { 1, 2 },
    },
    spec = {
      -- Top level groups (alphabetically organized)
      { "<leader>b", group = "Buffer", icon = "" },
      { "<leader>c", group = "Code", icon = "" },
      { "<leader>f", group = "Find", icon = "" },
      { "<leader>g", group = "Git", icon = "" },
      { "<leader>h", group = "Hunk", icon = "" },
      { "<leader>s", group = "Search", icon = "" },
      { "<leader>u", group = "UI", icon = "" },
      -- Custom submenu
      { "<leader><leader>", group = "Custom", icon = "" },
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)

    -- Snacks toggles with icons
    local Snacks = require("snacks")

    local static_desc = { enabled = "", disabled = "" }

    -- UI toggles
    Snacks.toggle.option("wrap", { name = "Wrap", wk_desc = static_desc }):map("<leader>uw")
    Snacks.toggle.option("relativenumber", { name = "Relative Number", wk_desc = static_desc }):map("<leader>ul")
    Snacks.toggle.option("spell", { name = "Spell", wk_desc = static_desc }):map("<leader>us")

    -- Diagnostic signs toggle
    Snacks.toggle({
      name = "Diagnostic Signs",
      wk_desc = static_desc,
      get = function()
        return vim.diagnostic.config().signs ~= false
      end,
      set = function(state)
        vim.diagnostic.config({ signs = state })
      end,
    }):map("<leader><leader>s")

    -- Diagnostic virtual text toggle
    Snacks.toggle({
      name = "Virtual Text",
      wk_desc = static_desc,
      get = function()
        return vim.diagnostic.config().virtual_text ~= false
      end,
      set = function(state)
        vim.diagnostic.config({
          virtual_text = state and {
            spacing = 4,
            source = "if_many",
            prefix = "",
          } or false,
        })
      end,
    }):map("<leader><leader>v")

  end,
  keys = {
    -- Custom menu (<leader><leader>)
    {
      "<leader><leader>f",
      function()
        require("fzf-lua").files({ cwd = vim.fn.getcwd() })
      end,
      desc = "Find files (cwd)",
    },
    {
      "<leader><leader>g",
      function()
        require("fzf-lua").live_grep({ cwd = vim.fn.getcwd() })
      end,
      desc = "Grep (cwd)",
    },
    {
      "<leader><leader>h",
      function()
        require("fzf-lua").files({ cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":h:h") })
      end,
      desc = "Find files (parent)",
    },
    {
      "<leader><leader>j",
      function()
        require("fzf-lua").live_grep({ cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":h:h") })
      end,
      desc = "Grep (parent)",
    },
    -- Help
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer keymaps",
    },
  },
}
