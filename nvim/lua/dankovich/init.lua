require("dankovich.remap")
require("dankovich.set")
require("dankovich.lazy")
require("dankovich.plugins.lualsp")
require("dankovich.plugins.jsonls")
require("dankovich.plugins.yamlls")
require("dankovich.plugins.prismals")
require("dankovich.plugins.diagnostics")
require("dankovich.plugins.clipboard-context").setup()

-- Set colorscheme
vim.cmd.colorscheme("gruvbox")
