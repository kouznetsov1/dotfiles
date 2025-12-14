local util = require("conform.util")

-- Helper to check if project uses biome
local function uses_biome(bufnr)
  local file_path = vim.api.nvim_buf_get_name(bufnr or 0)
  local file_dir = vim.fn.fnamemodify(file_path, ":h")
  local biome_config = vim.fn.findfile("biome.json", file_dir .. ";")
  if biome_config == "" then
    biome_config = vim.fn.findfile("biome.jsonc", file_dir .. ";")
  end
  return biome_config ~= ""
end

-- Dynamic formatter selection for JS/TS
local function js_formatter(bufnr)
  if uses_biome(bufnr) then
    return { "biome" }
  end
  return { "prettier" }
end

require("conform").setup({
  formatters_by_ft = {
    javascript = js_formatter,
    typescript = js_formatter,
    javascriptreact = js_formatter,
    typescriptreact = js_formatter,
    json = js_formatter,
    html = { "prettier" },
    css = { "prettier" },
    markdown = { "prettier" },
    yaml = { "prettier" },
    yml = { "prettier" },
    lua = { "stylua" },
    python = { "ruff_format" },
  },
  format_on_save = {
    timeout_ms = 5000,
    lsp_fallback = true,
  },
  formatters = {
    biome = {
      command = util.from_node_modules("biome"),
      cwd = util.root_file({ "biome.json", "biome.jsonc", ".git" }),
      args = { "format", "--stdin-file-path", "$FILENAME" },
      stdin = true,
    },
    prettier = {
      command = util.from_node_modules("prettier"),
      cwd = util.root_file({ ".git", "package.json" }),
      args = { "--stdin-filepath", "$FILENAME" },
      inherit = true,
      timeout_ms = 10000,
      env = {
        PRETTIER_CACHE = "true",
      },
    },
  },
})

