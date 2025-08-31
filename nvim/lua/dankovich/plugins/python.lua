-- Python LSP configuration
local lspconfig = require("lspconfig")

-- Enable completion capabilities
local capabilities = require("cmp_nvim_lsp").default_capabilities()

lspconfig.basedpyright.setup({
	capabilities = capabilities,
	settings = {
		basedpyright = {
			analysis = {
				typeCheckingMode = "basic",
			},
		},
	},
})