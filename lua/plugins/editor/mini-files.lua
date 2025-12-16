return {
  -- mini.files: File explorer with column view (Miller columns)
  {
    "echasnovski/mini.files",
    version = false,
    opts = {
      -- Content display options
      content = {
        filter = nil, -- Predicate for which entries to display
        sort = nil,   -- Function to sort entries
      },

      -- Keymappings within mini.files buffer
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

      -- General options
      options = {
        permanent_delete = true,          -- Delete permanently instead of to trash
        use_as_default_explorer = true,   -- Replace netrw as default file explorer
      },

      -- Window configuration
      windows = {
        max_number = math.huge,  -- Maximum number of windows to show
        preview = true,          -- Show preview of file/directory under cursor
        width_focus = 50,        -- Width of focused window
        width_nofocus = 20,      -- Width of non-focused windows
        width_preview = 100,     -- Width of preview window
      },
    },
    config = function(_, opts)
      require("mini.files").setup(opts)

      -- Remap Enter to behave like 'l' (open/expand entry)
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
