-- Mini.files: File explorer with Miller columns navigation (like macOS Finder).
-- Provides intuitive directory browsing with preview and vim-like keybindings.
local cfg = require("config.plugins").minifiles or {}
return {
  {
    "echasnovski/mini.files",
    enabled = cfg.enabled ~= false,
    branch = cfg.branch,
    version = false,
    opts = {
      content = {
        filter = nil,
        sort = nil,
      },
      mappings = {
        close = "q",
        go_in = "l",
        go_out = "h",
        go_in_plus = "L",
        mark_goto = "'",
        mark_set = "m",
        reset = "<BS>",
        reveal_cwd = "@",
        show_help = "g?",
        synchronize = "=",
        trim_left = "<",
        trim_right = ">",
      },
      options = {
        permanent_delete = true,
        use_as_default_explorer = true,
      },
      windows = {
        max_number = math.huge,
        preview = true,
        width_focus = 50,
        width_nofocus = 20,
        width_preview = 100,
      },
    },
    config = function(_, opts)
      require("mini.files").setup(opts)

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          vim.keymap.set("n", "<CR>", "l", { buffer = args.data.buf_id, remap = true })
        end,
      })
    end,
    keys = {
      {
        "<leader>e",
        function()
          require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
        end,
        desc = "Open mini.files (directory of current file)",
      },
      {
        "<leader>E",
        function()
          require("mini.files").open(vim.uv.cwd(), true)
        end,
        desc = "Open mini.files (cwd)",
      },
    },
  },
}
