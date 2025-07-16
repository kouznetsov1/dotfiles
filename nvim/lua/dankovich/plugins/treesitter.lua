require("nvim-treesitter.configs").setup({
  ensure_installed = { "typescript", "tsx", "javascript", "lua", "html", "json", "yaml", "prisma" },
  highlight = {
    enable = true,
  },
})
