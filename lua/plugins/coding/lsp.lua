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
      -- LSP keybindings (set when LSP attaches to buffer)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          -- Navigation (using fzf-lua)
          map("gd", function() require("fzf-lua").lsp_definitions() end, "Go to definition")
          map("gD", vim.lsp.buf.declaration, "Go to declaration")
          map("gr", function() require("fzf-lua").lsp_references() end, "Go to references")
          map("gI", function() require("fzf-lua").lsp_implementations() end, "Go to implementation")
          map("gy", function() require("fzf-lua").lsp_typedefs() end, "Go to type definition")

          -- Documentation
          map("K", vim.lsp.buf.hover, "Hover documentation")
          map("gK", vim.lsp.buf.signature_help, "Signature help")

          -- Code actions (using fzf-lua)
          map("<leader>ca", function() require("fzf-lua").lsp_code_actions() end, "Code action")
          map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")

          -- Diagnostics (using fzf-lua)
          map("<leader>cd", function() require("fzf-lua").diagnostics_document() end, "Document diagnostics")
          map("[d", vim.diagnostic.goto_prev, "Previous diagnostic")
          map("]d", vim.diagnostic.goto_next, "Next diagnostic")

          -- Format
          map("<leader>cf", function()
            vim.lsp.buf.format({ async = true })
          end, "Format buffer")
        end,
      })

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
        "ruby_lsp",
      },
      -- Automatically enable all installed servers
      automatic_enable = true,
    },
  },
}
