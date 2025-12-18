-- nvim-lint: Asynchronous linter plugin complementary to LSP.
-- Runs external linters and displays diagnostics in neovim.
--
-- CPPCHECK CACHE:
-- Uses ~/.cache/nvim-cppcheck/[project-name]-[hash]/ for faster incremental analysis.
-- Always start neovim from your project root for consistent caching.
-- To clear: rm -rf ~/.cache/nvim-cppcheck/
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
    -- Uses the default nvim-lint parser template: {file}:{line}:{column}: [{id}] {severity}: {message}
    local cppcheck = lint.linters.cppcheck
    cppcheck.args = {
      "--enable=all",
      "--inconclusive",
      function()
        return vim.bo.filetype == "cpp" and "--language=c++" or "--language=c"
      end,
      "--std=c++17",
      "--suppress=missingIncludeSystem",
      "--inline-suppr",
      "--quiet",
      "--template={file}:{line}:{column}: [{id}] {severity}: {message}",
      function()
        -- Use project-specific cache directory
        local project_root = vim.fn.getcwd()
        local project_name = vim.fn.fnamemodify(project_root, ":t")
        local path_hash = vim.fn.sha256(project_root):sub(1, 8)
        local cache_dir = vim.fn.expand("~/.cache/nvim-cppcheck/" .. project_name .. "-" .. path_hash)
        vim.fn.mkdir(cache_dir, "p")
        return "--cppcheck-build-dir=" .. cache_dir
      end,
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
