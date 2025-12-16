return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    -- Remove background from diagnostic virtual text
    vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = "#db4b4b", bg = "NONE" })
    vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { fg = "#e0af68", bg = "NONE" })
    vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", { fg = "#0db9d7", bg = "NONE" })
    vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", { fg = "#1abc9c", bg = "NONE" })

    -- Configure diagnostics to show source (clangd, cppcheck, etc.)
    vim.diagnostic.config({
      underline = true,
      update_in_insert = false,
      virtual_text = {
        spacing = 4,
        source = false,
        prefix = "",
        format = function(diagnostic)
          if diagnostic.source then
            return string.format("[%s] %s", diagnostic.source, diagnostic.message)
          end
          return diagnostic.message
        end,
      },
      float = {
        source = true, -- Show source in float window
        border = "rounded",
        focusable = false,
      },
      severity_sort = true,
    })

    return opts
  end,
  keys = {
    -- gl keymap for line diagnostics with source info
    {
      "gl",
      function()
        vim.diagnostic.open_float(0, {
          scope = "line",
          border = "rounded",
          source = true, -- Show diagnostic source
          focusable = false,
          close_events = { "CursorMoved", "InsertEnter", "BufHidden" },
        })
      end,
      desc = "Line Diagnostics",
    },
  },
}
