require("tailwind-tools").setup({
  document_color = {
    enabled = true,
    kind = "inline", -- Shows color inline with the tailwind icon
    inline_symbol = "󰝤 ",
    debounce = 200,
  },
  conceal = {
    enabled = false, -- Start with conceal disabled
    symbol = "󱏿",
    highlight = {
      fg = "#38BDF8",
    },
  },
  cmp = {
    highlight = "foreground", -- Show colors in completion menu
  },
})