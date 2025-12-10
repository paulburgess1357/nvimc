return {
  -- Mason: LSP installer
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  -- Mason-LSPconfig bridge
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("mason-lspconfig").setup({
        -- Add LSPs you want auto-installed here
        ensure_installed = {
          "lua_ls",  -- Lua
          "clangd",  -- C/C++
          -- "tsserver",  -- TypeScript/JavaScript
          -- "rust_analyzer",  -- Rust
          -- "pyright",  -- Python
        },
        -- Auto-setup installed servers
        automatic_installation = true,
      })

      -- Auto-setup handlers for installed LSPs
      require("mason-lspconfig").setup_handlers({
        -- Default handler for all servers
        function(server_name)
          require("lspconfig")[server_name].setup({})
        end,

        -- Custom configuration for clangd
        ["clangd"] = function()
          require("lspconfig").clangd.setup({
            cmd = {
              "clangd",
              "--background-index",
              "--clang-tidy",
              "--header-insertion=iwyu",
              "--completion-style=detailed",
              "--function-arg-placeholders",
              "--error-limit=0",
              "--enable-config",  -- Enables .clangd config file
            },
            filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
            root_dir = require("lspconfig").util.root_pattern(
              ".clangd",
              ".clang-tidy",
              ".clang-format",
              "compile_commands.json",
              "compile_flags.txt",
              ".git"
            ),
            capabilities = {
              offsetEncoding = { "utf-16" },
            },
          })
        end,
      })
    end,
  },

  -- LSP configurations
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
  },
}
