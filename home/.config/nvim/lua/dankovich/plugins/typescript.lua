-- Enable completion capabilities
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local lspconfig = require("lspconfig")

-- Using vtsls for TypeScript plugin support (Effect LSP)
-- vtsls automatically detects and uses TypeScript plugins from tsconfig.json
require("lspconfig.configs").vtsls = require("vtsls").lspconfig

lspconfig.vtsls.setup({
  capabilities = capabilities,
  root_dir = function(fname)
    return require("lspconfig.util").root_pattern("package.json", "tsconfig.json")(fname)
  end,
  settings = {
    vtsls = {
      -- Enable TypeScript plugins from tsconfig.json
      enableMoveToFileCodeAction = true,
      autoUseWorkspaceTsdk = true,
      experimental = {
        maxInlayHintLength = 30,
        completion = {
          enableServerSideFuzzyMatch = true
        }
      }
    },
    typescript = {
      tsserver = {
        maxTsServerMemory = 4096,
        pluginPaths = { "./node_modules" },
        watchOptions = {
          excludeDirectories = { "**/vendor/**", "**/node_modules/**", "**/.turbo/**" }
        }
      },
      preferences = {
        importModuleSpecifier = "relative"
      },
      inlayHints = {
        parameterNames = { enabled = "all" },
        parameterTypes = { enabled = true },
        variableTypes = { enabled = true },
        propertyDeclarationTypes = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        enumMemberValues = { enabled = true }
      },
      updateImportsOnFileMove = { enabled = "always" },
      suggest = {
        completeFunctionCalls = true
      }
    }
  }
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