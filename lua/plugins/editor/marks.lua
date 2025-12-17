-- marks.nvim: Display marks in the sign column with visual indicators.
-- Shows lowercase/uppercase marks and provides quick navigation between them.
return {
  "chentoast/marks.nvim",
  event = "VeryLazy",
  opts = {
    default_mappings = true,
    signs = true,
    cyclic = true,
    refresh_interval = 250,
    sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
  },
}
