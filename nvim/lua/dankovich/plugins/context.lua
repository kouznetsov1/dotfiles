require("treesitter-context").setup({
  enable = false, -- Start disabled since it's annoying
  max_lines = 3, -- How many lines the window should span
  min_window_height = 0,
  line_numbers = true,
  multiline_threshold = 20, -- Maximum number of lines to show for a single context
  trim_scope = 'outer',
  mode = 'cursor', -- Line used to calculate context
  separator = nil, -- No separator line
  zindex = 20,
})

-- Keybinding to toggle context
vim.keymap.set("n", "<leader>tc", function()
  require("treesitter-context").toggle()
end, { desc = "Toggle context" })