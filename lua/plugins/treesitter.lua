return {
  -- Treesitter: Advanced syntax parsing and highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false, -- Treesitter should not be lazy-loaded
    main = "nvim-treesitter.configs",
    opts = {
      -- Languages to auto-install
      ensure_installed = {
        "c",
        "cpp",
        "lua",
        "vim",
        "vimdoc",
        "python",
        "bash",
        "markdown",
        "markdown_inline",
        "ruby",
      },
      -- Install parsers synchronously (only applied to `ensure_installed`)
      sync_install = false,
      -- Automatically install missing parsers when entering buffer
      auto_install = true,
      -- Syntax highlighting
      highlight = {
        enable = true,
        -- Disable for very large files
        disable = function(lang, buf)
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,
      },
      -- Indentation based on treesitter
      indent = {
        enable = true,
      },
      -- Incremental selection
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "gnn",
          node_incremental = "grn",
          scope_incremental = "grc",
          node_decremental = "grm",
        },
      },
    },
  },
}
