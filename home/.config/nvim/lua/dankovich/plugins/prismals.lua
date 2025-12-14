local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.lsp.config.prismals = {
  cmd = { "prisma-language-server", "--stdio" },
  filetypes = { "prisma" },
  single_file_support = true,
  capabilities = capabilities,
  settings = {
    prisma = {
      prismaFmtBinPath = "",
    },
  },
}

vim.lsp.enable("prismals")