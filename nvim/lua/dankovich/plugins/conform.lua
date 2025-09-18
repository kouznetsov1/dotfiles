local util = require("conform.util")

require("conform").setup({
  formatters_by_ft = {
    javascript = { "prettier" },
    typescript = { "prettier" },
    javascriptreact = { "prettier" },
    typescriptreact = { "prettier" },
    json = { "prettier" },
    html = { "prettier" },
    css = { "prettier" },
    markdown = { "prettier" },
    yaml = { "prettier" },
    yml = { "prettier" },
    lua = { "stylua" },
    python = { "ruff_format" },
  },
  format_on_save = {
    timeout_ms = 5000, -- Increased timeout for large projects
    lsp_fallback = true,
  },
  formatters = {
    prettier = {
      -- Find prettier relative to the file being formatted
      command = util.from_node_modules("prettier"),
      -- Let prettier handle config resolution itself by running from the file's directory
      cwd = util.root_file({ ".git", "package.json" }),
      args = { "--stdin-filepath", "$FILENAME" },
      -- Ensure prettier can find its config by not overriding its natural resolution
      inherit = true,
      -- Increase timeout for prettier specifically
      timeout_ms = 10000,
      -- Use cache to speed up formatting
      env = {
        PRETTIER_CACHE = "true",
      },
    },
  },
})

