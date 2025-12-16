return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "modern",
  },
  keys = {
    {
      "<leader><leader>",
      group = "Custom",
    },
    -- Find/Grep shortcuts
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
      desc = "Find files (root)",
    },
    {
      "<leader><leader>j",
      function()
        require("fzf-lua").live_grep({ cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":h:h") })
      end,
      desc = "Grep (root)",
    },
    -- Diagnostic toggles
    {
      "<leader><leader>d",
      function()
        -- Toggle between icons and text
        vim.g.diagnostic_signs_style = vim.g.diagnostic_signs_style == "text" and "icons" or "text"
        local style = vim.g.diagnostic_signs_style

        local signs = {
          Error = style == "icons" and "" or "E",
          Warn = style == "icons" and "" or "W",
          Hint = style == "icons" and "" or "H",
          Info = style == "icons" and "" or "I",
        }

        for name, icon in pairs(signs) do
          vim.fn.sign_define("DiagnosticSign" .. name, { text = icon, texthl = "DiagnosticSign" .. name })
        end

        vim.notify("Diagnostic signs style: " .. style)
      end,
      desc = "Toggle Signs Style",
    },
    {
      "<leader><leader>v",
      function()
        local config = vim.diagnostic.config()
        local new_virtual_text = not config.virtual_text

        vim.diagnostic.config({
          virtual_text = new_virtual_text and {
            spacing = 4,
            source = false,
            prefix = "",
            format = function(diagnostic)
              if diagnostic.source then
                return string.format("[%s] %s", diagnostic.source, diagnostic.message)
              end
              return diagnostic.message
            end,
          } or false,
        })

        vim.notify("Diagnostic virtual text " .. (new_virtual_text and "enabled" or "disabled"))
      end,
      desc = "Toggle Virtual Text",
    },
  },
}
