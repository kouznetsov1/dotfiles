local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.lsp.config.yamlls = {
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = { "yaml", "yml" },
  single_file_support = true,
  capabilities = capabilities,
  settings = {
    yaml = {
      hover = true,
      completion = true,
      validate = true,
      schemas = require("schemastore").yaml.schemas(),
    },
  },
}

vim.lsp.enable("yamlls")