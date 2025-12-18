-- Treesitter: Advanced syntax highlighting, indentation, and code understanding.
-- New main branch API (Neovim 0.11+). Requires: tar, curl, tree-sitter-cli, C compiler.
local cfg = require("config.plugins").treesitter or {}
return {
  {
    "nvim-treesitter/nvim-treesitter",
    enabled = cfg.enabled ~= false,
    branch = cfg.branch,
    build = ":TSUpdate",
    lazy = false,
    config = function()
      -- Install parsers
      require("nvim-treesitter").install({
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
        "json",
        "yaml",
        "toml",
        "dockerfile",
      })

      -- Enable highlighting and indentation for all filetypes
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          -- Skip large files
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
          if ok and stats and stats.size > max_filesize then
            return
          end

          -- Enable highlighting (silently fail if no parser)
          pcall(vim.treesitter.start, args.buf)

          -- Enable indentation
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
}
