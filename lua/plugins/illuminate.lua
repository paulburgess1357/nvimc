return {
  "RRethy/vim-illuminate",
  event = "VeryLazy",
  opts = {
    delay = 200,
    large_file_cutoff = 20000,
    max_lines = 100,
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
      "dashboard",
      "TelescopePrompt",
      "lazy",
      "mason",
    },
    min_count_to_highlight = 1,
  },
  config = function(_, opts)
    require("illuminate").configure(opts)

    -- Set highlight colors
    vim.api.nvim_set_hl(0, "IlluminatedWordText", { bg = "#3A3A4A", underline = true })
    vim.api.nvim_set_hl(0, "IlluminatedWordRead", { bg = "#3A3A4A", underline = true })
    vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { bg = "#4A4A5A", underline = true, bold = true })
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
