local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

lspconfig.yamlls.setup({
  capabilities = capabilities,
  settings = {
    yaml = {
      hover = true,
      completion = true,
      validate = true,
      schemas = require("schemastore").yaml.schemas(),
    },
  },
  filetypes = { "yaml", "yml" },
})