-- Fzf-lua: Fuzzy finder powered by fzf for files, grep, LSP, and more.
-- Provides fast, native fuzzy searching with preview and LSP integration.
return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = { "FzfLua" },
  config = function(_, opts)
    require("fzf-lua").setup(opts)
    local fzf = require("fzf-lua")
    local cmd = vim.api.nvim_create_user_command
    cmd("Symbols", fzf.lsp_document_symbols, { desc = "Document symbols" })
    cmd("Marks", fzf.marks, { desc = "Marks" })
    cmd("Files", fzf.files, { desc = "Find files" })
    cmd("Buffers", fzf.buffers, { desc = "Buffers" })
    cmd("Rg", fzf.live_grep, { desc = "Live grep" })
    cmd("Grep", fzf.live_grep, { desc = "Live grep" })
    cmd("Help", fzf.help_tags, { desc = "Help tags" })
    cmd("Commands", fzf.commands, { desc = "Commands" })
    cmd("Keymaps", fzf.keymaps, { desc = "Keymaps" })
  end,
  opts = function()
    local actions = require("fzf-lua.actions")
    return {
      "default-title",
      keymap = {
        fzf = {
          ["ctrl-j"] = "down",
          ["ctrl-k"] = "up",
        },
        builtin = {
          ["<C-d>"] = "preview-page-down",
          ["<C-u>"] = "preview-page-up",
        },
      },
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
      files = {
        cwd_prompt = false,
      },
      grep = {
        rg_glob = true,
      },
      lsp = {
        async_or_timeout = 5000,
        includeDeclaration = false,
      },
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
  keys = {
    -- Find
    { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Files" },
    { "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent files" },
    { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
    -- Grep
    { "<leader>sg", "<cmd>FzfLua live_grep<cr>", desc = "Grep" },
    { "<leader>sw", "<cmd>FzfLua grep_cword<cr>", desc = "Word under cursor" },
    { "<leader>sW", "<cmd>FzfLua grep_cWORD<cr>", desc = "WORD under cursor" },
    { "<leader>sv", "<cmd>FzfLua grep_visual<cr>", mode = "v", desc = "Selection" },
    { "<leader>sb", "<cmd>FzfLua lgrep_curbuf<cr>", desc = "Buffer" },
    -- Git
    { "<leader>gf", "<cmd>FzfLua git_files<cr>", desc = "Git files" },
    { "<leader>gc", "<cmd>FzfLua git_commits<cr>", desc = "Commits" },
    { "<leader>gb", "<cmd>FzfLua git_branches<cr>", desc = "Branches" },
    { "<leader>gs", "<cmd>FzfLua git_status<cr>", desc = "Status" },
    -- LSP
    { "<leader>ss", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Document symbols" },
    { "<leader>sS", "<cmd>FzfLua lsp_workspace_symbols<cr>", desc = "Workspace symbols" },
    -- Misc
    { "<leader>:", "<cmd>FzfLua command_history<cr>", desc = "Command history" },
    { "<leader>fh", "<cmd>FzfLua help_tags<cr>", desc = "Help" },
    { "<leader>fk", "<cmd>FzfLua keymaps<cr>", desc = "Keymaps" },
    { "<leader>fc", "<cmd>FzfLua colorschemes<cr>", desc = "Colorschemes" },
    { "<leader>fm", "<cmd>FzfLua marks<cr>", desc = "Marks" },
    { "<leader>fR", "<cmd>FzfLua registers<cr>", desc = "Registers" },
    { "<leader>fd", "<cmd>FzfLua diagnostics_document<cr>", desc = "Diagnostics" },
    { "<leader>fD", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Workspace diagnostics" },
    { "<leader>fq", "<cmd>FzfLua quickfix<cr>", desc = "Quickfix" },
    { "<leader>fl", "<cmd>FzfLua loclist<cr>", desc = "Location list" },
    { "<leader>f/", "<cmd>FzfLua search_history<cr>", desc = "Search history" },
    -- Resume
    { "<leader><cr>", "<cmd>FzfLua resume<cr>", desc = "Resume last picker" },
  },
}
