return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = { "Symbols" },
  config = function(_, opts)
    require("fzf-lua").setup(opts)

    -- Create custom command for document symbols
    vim.api.nvim_create_user_command("Symbols", function()
      require("fzf-lua").lsp_document_symbols()
    end, { desc = "Show document symbols (FzfLua)" })
  end,
  opts = function()
    local actions = require("fzf-lua.actions")
    return {
      winopts = {
        height = 0.85,
        width = 0.80,
        preview = {
          default = "builtin",
          border = "border",
          wrap = "nowrap",
          hidden = "nohidden",
          vertical = "down:45%",
          horizontal = "right:60%",
          layout = "flex",
          flip_columns = 120,
        },
      },
      -- Open multiple selections as buffers, not quickfix
      actions = {
        files = {
          ["default"] = actions.file_edit,
          ["ctrl-s"] = actions.file_split,
          ["ctrl-v"] = actions.file_vsplit,
          ["ctrl-t"] = actions.file_tabedit,
        },
      },
    }
  end,
}
