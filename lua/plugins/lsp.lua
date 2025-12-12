return {
  -- Mason: LSP installer
  -- Provides a UI to install and manage LSP servers, linters, and formatters
  {
    "williamboman/mason.nvim",
    opts = {},
  },

  -- LSP configurations
  -- Provides default configurations for various language servers
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      -- Custom clangd configuration using vim.lsp.config (Neovim 0.11+)
      vim.lsp.config.clangd = {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders=true",
          "--enable-config",
        },
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto", "h", "hpp", "hxx", "cc", "cxx" },
        root_markers = {
          ".clangd",
          ".clang-tidy",
          ".clang-format",
          "compile_commands.json",
          "compile_flags.txt",
          ".git",
        },
      }
    end,
  },

  -- Mason-LSPconfig bridge
  -- Automatically enables LSP servers installed via Mason
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      -- LSP servers to auto-install
      ensure_installed = {
        "lua_ls",
        "clangd",
        "pyright",
      },
      -- Automatically enable all installed servers
      automatic_enable = true,
    },
  },
}
