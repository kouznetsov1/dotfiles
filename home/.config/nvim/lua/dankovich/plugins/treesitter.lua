if vim.fn.has("nvim-0.12") == 0 then
	vim.notify("nvim-treesitter main requires Neovim 0.12 or newer", vim.log.levels.ERROR)
	return
end

local parsers = {
	"bash",
	"css",
	"html",
	"javascript",
	"json",
	"lua",
	"markdown",
	"markdown_inline",
	"prisma",
	"query",
	"tsx",
	"typescript",
	"vim",
	"vimdoc",
	"yaml",
}

local filetypes = {
	"bash",
	"css",
	"html",
	"javascript",
	"javascriptreact",
	"json",
	"jsonc",
	"lua",
	"markdown",
	"prisma",
	"query",
	"typescript",
	"typescriptreact",
	"vim",
	"vimdoc",
	"yaml",
}

local treesitter = require("nvim-treesitter")

treesitter.setup({
	install_dir = vim.fn.stdpath("data") .. "/site",
})

vim.treesitter.language.register("tsx", "typescriptreact")
vim.treesitter.language.register("javascript", "javascriptreact")
vim.treesitter.language.register("json", "jsonc")

treesitter.install(parsers)

vim.api.nvim_create_autocmd("FileType", {
	pattern = filetypes,
	callback = function(args)
		pcall(vim.treesitter.start, args.buf)
	end,
})
