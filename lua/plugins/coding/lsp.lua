-- LSP: Language Server Protocol support for code intelligence.
-- Provides auto-completion, go-to-definition, diagnostics, and code actions.
return {
  -- Mason: Package manager for LSP servers, linters, and formatters
  {
    "mason-org/mason.nvim",
    opts = {},
  },

  -- LSP configurations and keybindings
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
    },
    config = function()
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
          map("[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Previous diagnostic")
          map("]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic")

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
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
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

  -- Mason-LSPconfig: Bridge between Mason and lspconfig
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = {
        "lua_ls",
        "clangd",
        "pyright",
        "ruby_lsp",
      },
      automatic_enable = true,
    },
  },
}
