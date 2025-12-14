-- Python LSP configuration

-- Enable completion capabilities
local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.lsp.config.basedpyright = {
	cmd = { "basedpyright-langserver", "--stdio" },
	filetypes = { "python" },
	single_file_support = true,
	capabilities = capabilities,
	settings = {
		basedpyright = {
			analysis = {
				typeCheckingMode = "basic",
			},
		},
	},
}

vim.lsp.enable("basedpyright")