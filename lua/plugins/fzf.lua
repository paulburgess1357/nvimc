return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
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
  },
}
