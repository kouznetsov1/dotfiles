vim.lsp.config.rust_analyzer = {
	cmd = { "rust-analyzer" },
	filetypes = { "rust" },
	root_markers = { "Cargo.toml", "rust-project.json" },
	settings = {
		["rust-analyzer"] = {
			checkOnSave = {
				command = "clippy",
			},
			inlayHints = {
				parameterHints = { enable = true },
				typeHints = { enable = true },
			},
		},
	},
}

vim.lsp.enable("rust_analyzer")
