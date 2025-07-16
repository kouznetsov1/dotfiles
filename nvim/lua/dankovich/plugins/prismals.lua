local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

lspconfig.prismals.setup({
  capabilities = capabilities,
  settings = {
    prisma = {
      prismaFmtBinPath = "",
    },
  },
})