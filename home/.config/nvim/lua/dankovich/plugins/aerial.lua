require("aerial").setup({
	-- Prefer LSP symbols for semantic outlines; Tree-sitter remains useful as a fallback.
	backends = { "lsp", "treesitter", "markdown", "man" },
	attach_mode = "window",
	show_guides = true,
	layout = {
		min_width = 28,
		max_width = { 40, 0.25 },
		default_direction = "prefer_left",
	},
})
