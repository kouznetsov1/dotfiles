-- copy pasted from
-- https://lazy.folke.io/installation

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		-- import your plugins
		{
			"ibhagwan/fzf-lua",
			-- optional for icon support
			dependencies = { "nvim-tree/nvim-web-devicons" },
			-- or if using mini.icons/mini.nvim
			-- dependencies = { "echasnovski/mini.icons" },
			opts = {},
		},

		-- Colorscheme
		{ "ellisonleao/gruvbox.nvim", priority = 1000, config = true },

		{
			"nvim-treesitter/nvim-treesitter",
			branch = "master",
			lazy = false,
			build = ":TSUpdate",
			config = function()
				require("dankovich.plugins.treesitter")
			end,
		},

		-- Auto close/rename HTML tags
		{
			"windwp/nvim-ts-autotag",
			event = "InsertEnter",
			config = function()
				require("nvim-ts-autotag").setup()
			end,
		},

		-- Show context at top of screen
		{
			"nvim-treesitter/nvim-treesitter-context",
			event = "BufReadPost",
			config = function()
				require("dankovich.plugins.context")
			end,
		},
		{ "neovim/nvim-lspconfig", branch = "master", lazy = false },

		-- Mason for LSP server management
		{
			"williamboman/mason.nvim",
			build = ":MasonUpdate",
			config = function()
				require("mason").setup()
			end,
		},
		{
			"williamboman/mason-lspconfig.nvim",
			dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
			config = function()
				require("mason-lspconfig").setup({
					ensure_installed = {
						"lua_ls",
						"jsonls",
						"yamlls",
						"tailwindcss",
						"prismals",
					},
					automatic_installation = true,
				})
			end,
		},

		-- SchemaStore for JSON/YAML schemas
		{
			"b0o/SchemaStore.nvim",
			lazy = true,
			version = false,
		},

		{
			"pmizio/typescript-tools.nvim",
			dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
			config = function()
				require("dankovich.plugins.typescript")
			end,
		},

		-- Tailwind CSS tools
		{
			"luckasRanarison/tailwind-tools.nvim",
			name = "tailwind-tools",
			build = ":UpdateRemotePlugins",
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
				"neovim/nvim-lspconfig",
			},
			config = function()
				require("dankovich.plugins.tailwind")
			end,
		},

		-- Git signs in gutter
		{
			"lewis6991/gitsigns.nvim",
			event = "BufReadPre",
			config = function()
				require("dankovich.plugins.gitsigns")
			end,
		},

		-- Diff viewer
		{
			"sindrets/diffview.nvim",
			dependencies = { "nvim-lua/plenary.nvim" },
			cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles" },
			config = function()
				require("diffview").setup({
					enhanced_diff_hl = true,
					use_icons = true,
					signs = {
						fold_closed = "",
						fold_open = "",
					},
				})
			end,
		},

		-- Status line
		{
			"nvim-lualine/lualine.nvim",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			config = function()
				require("dankovich.plugins.lualine")
			end,
		},

		-- File explorer (edit directories like buffers)
		{
			"stevearc/oil.nvim",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			config = function()
				require("dankovich.plugins.oil")
			end,
		},

		-- Harpoon for fast file navigation
		{
			"ThePrimeagen/harpoon",
			branch = "harpoon2",
			dependencies = { "nvim-lua/plenary.nvim" },
			config = function()
				require("dankovich.plugins.harpoon")
			end,
		},

		-- Formatter that respects project configs
		{
			"stevearc/conform.nvim",
			event = { "BufWritePre" },
			cmd = { "ConformInfo" },
			config = function()
				require("dankovich.plugins.conform")
			end,
		},

		-- Linter
		{
			"mfussenegger/nvim-lint",
			event = { "BufReadPre", "BufNewFile" },
			config = function()
				require("dankovich.plugins.lint")
			end,
		},

		-- Auto-close brackets
		{
			"windwp/nvim-autopairs",
			event = "InsertEnter",
			config = function()
				require("dankovich.plugins.autopairs")
			end,
		},

		-- Autocompletion
		{
			"hrsh7th/nvim-cmp",
			event = { "InsertEnter", "CmdlineEnter" },
			dependencies = {
				"hrsh7th/cmp-nvim-lsp",
				"hrsh7th/cmp-buffer",
				"hrsh7th/cmp-path",
				"hrsh7th/cmp-cmdline",
				"hrsh7th/cmp-nvim-lsp-signature-help",
				"hrsh7th/cmp-nvim-lsp-document-symbol",
				{
					"David-Kunz/cmp-npm",
					dependencies = { "nvim-lua/plenary.nvim" },
					ft = "json",
					config = function()
						require("cmp-npm").setup({})
					end,
				},
			},
			config = function()
				require("dankovich.plugins.cmp")
			end,
		},
	},
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "habamax" } },
	-- automatically check for plugin updates
	checker = { enabled = true },
})
