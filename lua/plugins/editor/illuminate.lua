-- Vim-illuminate: Highlights other uses of the word under the cursor.
-- Uses LSP, treesitter, and regex providers for accurate symbol matching.
local cfg = require("config.plugins").illuminate or {}
return {
  "RRethy/vim-illuminate",
  enabled = cfg.enabled ~= false,
  branch = cfg.branch,
  event = "VeryLazy",
  opts = {
    delay = 100,
    large_file_cutoff = 10000,
    under_cursor = true,
    providers = {
      "lsp",
      "treesitter",
      "regex",
    },
    filetypes_denylist = {
      "dirbuf",
      "dirvish",
      "fugitive",
      "alpha",
      "NvimTree",
      "neo-tree",
      "minifiles",
      "dashboard",
      "TelescopePrompt",
      "lazy",
      "mason",
    },
    min_count_to_highlight = 1,
  },
  config = function(_, opts)
    require("illuminate").configure(opts)
  end,
  keys = {
    {
      "]]",
      function()
        require("illuminate").goto_next_reference(false)
      end,
      desc = "Next Reference",
    },
    {
      "[[",
      function()
        require("illuminate").goto_prev_reference(false)
      end,
      desc = "Prev Reference",
    },
  },
}
