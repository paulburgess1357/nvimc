-- nvim-lint: Asynchronous linter plugin complementary to LSP.
-- Runs external linters and displays diagnostics in neovim.
return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    -- Configure linters by filetype
    lint.linters_by_ft = {
      c = { "cppcheck" },
      cpp = { "cppcheck" },
      sh = { "shellcheck" },
      bash = { "shellcheck" },
    }

    -- Customize cppcheck arguments
    lint.linters.cppcheck.args = {
      "--enable=warning,style,performance,portability",
      "--suppress=missingIncludeSystem",
      "--inline-suppr",
      "--quiet",
      function() return vim.fn.expand("%:p") end,
    }

    -- Create autocmd to trigger linting
    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
    vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave", "BufEnter" }, {
      group = lint_augroup,
      callback = function()
        -- Only lint if buffer is modifiable
        if vim.opt_local.modifiable:get() then
          lint.try_lint()
        end
      end,
    })
  end,
  keys = {
    {
      "<leader>cl",
      function()
        require("lint").try_lint()
      end,
      desc = "Trigger linting",
    },
  },
}
