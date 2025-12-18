-- inc-rename.nvim: Incremental LSP rename with live preview.
-- Shows real-time preview of all changes as you type the new name.
return {
  "smjonas/inc-rename.nvim",
  cmd = "IncRename",
  opts = {
    preview_empty_name = false,
    show_message = true,
    save_in_cmdline_history = true,
  },
  keys = {
    {
      "<leader>cr",
      function()
        return ":IncRename " .. vim.fn.expand("<cword>")
      end,
      expr = true,
      desc = "Rename (inc-rename)",
    },
  },
}
