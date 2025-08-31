require("dankovich.remap")
require("dankovich.set")
require("dankovich.lazy")

-- Defer LSP plugin loading until after lazy.nvim initialization
vim.api.nvim_create_autocmd("User", {
    pattern = "LazyVimStarted",
    callback = function()
        require("dankovich.plugins.lualsp")
        require("dankovich.plugins.jsonls")
        require("dankovich.plugins.yamlls")
        require("dankovich.plugins.prismals")
        require("dankovich.plugins.python")
        require("dankovich.plugins.diagnostics")
        require("dankovich.plugins.clipboard-context").setup()
    end,
})

-- Set colorscheme
vim.cmd.colorscheme("gruvbox")
