-- Enable completion capabilities
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local lspconfig = require("lspconfig")

-- Use only the native TS7 LSP. Detect it via the @typescript/native alias
-- (Ultra keeps the JavaScript compiler under `typescript`) or TypeScript 7+
-- installed under its real name.
local function find_native_tsc(path)
  for dir in vim.fs.parents(path) do
    local nm = dir .. "/node_modules"
    local native = nm .. "/@typescript/native/bin/tsc"
    if vim.fn.executable(native) == 1 then
      return native
    end
    local tsc = nm .. "/typescript/bin/tsc"
    if vim.fn.executable(tsc) == 1 then
      local f = io.open(nm .. "/typescript/package.json")
      if f then
        local ok, pkg = pcall(vim.json.decode, f:read("*a"))
        f:close()
        local major = ok and type(pkg.version) == "string" and tonumber(pkg.version:match("^(%d+)"))
        if major and major >= 7 then
          return tsc
        end
      end
    end
  end
end

local lsp_configs = require("lspconfig.configs")

if not lsp_configs.ts_native then
  lsp_configs.ts_native = {
    default_config = {
      cmd = { "tsc", "--lsp", "--stdio" },
      filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
      root_dir = require("lspconfig.util").root_pattern("tsconfig.json", "package.json"),
    },
  }
end

lspconfig.ts_native.setup({
  capabilities = capabilities,
  single_file_support = false,
  root_dir = function(fname)
    if find_native_tsc(fname) then
      return require("lspconfig.util").root_pattern("tsconfig.json", "package.json")(fname)
    end
  end,
  on_new_config = function(new_config, root_dir)
    local bin = find_native_tsc(root_dir)
    if bin then
      new_config.cmd = { bin, "--lsp", "--stdio" }
    end
  end,
})

-- LSP keybindings (only active when LSP is attached)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf }
    -- Go to definition
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    -- Show hover info (types, docs)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    -- Find all references
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    -- Rename symbol
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    -- Code actions (quick fixes)
    vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
    -- Format file (using conform.nvim which respects prettier config)
    vim.keymap.set("n", "<leader>f", function()
      require("conform").format({ async = true })
    end, opts)
    -- Copy diagnostic to clipboard
    vim.keymap.set("n", "dc", function()
      local line_diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
      if #line_diagnostics > 0 then
        local messages = {}
        for _, diagnostic in ipairs(line_diagnostics) do
          table.insert(messages, diagnostic.message)
        end
        local text = table.concat(messages, "\n")
        vim.fn.setreg("+", text)
        vim.notify("Diagnostic copied to clipboard")
      else
        vim.notify("No diagnostics on current line")
      end
    end, opts)
  end,
})