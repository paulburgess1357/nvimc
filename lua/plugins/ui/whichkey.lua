-- Which-key.nvim: Displays available keybindings in a popup as you type.
-- Helps discover and remember keymaps with visual hints and groupings.
return {
  "folke/which-key.nvim",
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
    {
      "<leader><leader>s",
      function()
        local config = vim.diagnostic.config()
        local new_signs = not config.signs
        vim.diagnostic.config({ signs = new_signs })
        vim.notify("Diagnostic signs " .. (new_signs and "enabled" or "disabled"))
      end,
      desc = "Toggle diagnostic signs",
    },
    {
      "<leader><leader>v",
      function()
        local config = vim.diagnostic.config()
        local new_virtual_text = not config.virtual_text
        vim.diagnostic.config({
          virtual_text = new_virtual_text and {
            spacing = 4,
            source = "if_many",
            prefix = "",
          } or false,
        })
        vim.notify("Diagnostic virtual text " .. (new_virtual_text and "enabled" or "disabled"))
      end,
      desc = "Toggle virtual text",
    },
    -- UI toggles
    {
      "<leader>uw",
      function()
        vim.wo.wrap = not vim.wo.wrap
        vim.notify("Wrap " .. (vim.wo.wrap and "enabled" or "disabled"))
      end,
      desc = "Toggle word wrap",
    },
    {
      "<leader>ul",
      function()
        vim.wo.relativenumber = not vim.wo.relativenumber
        vim.notify("Relative numbers " .. (vim.wo.relativenumber and "enabled" or "disabled"))
      end,
      desc = "Toggle relative numbers",
    },
    {
      "<leader>us",
      function()
        vim.wo.spell = not vim.wo.spell
        vim.notify("Spell check " .. (vim.wo.spell and "enabled" or "disabled"))
      end,
      desc = "Toggle spell check",
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
