local cmp = require("cmp")

cmp.setup({
  mapping = cmp.mapping.preset.insert({
    -- Scroll docs
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    
    -- Complete
    ["<C-Space>"] = cmp.mapping.complete(),
    
    -- Abort
    ["<C-e>"] = cmp.mapping.abort(),
    
    -- Accept completion
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    
    -- Navigate items
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
  }),
  
  sources = cmp.config.sources({
    { name = "nvim_lsp" },                -- LSP completions
    { name = "nvim_lsp_signature_help" }, -- Function signatures as you type
    { name = "npm", keyword_length = 4 }, -- NPM packages (min 4 chars)
    { name = "buffer" },                  -- Buffer completions
    { name = "path" },                    -- Path completions
  }),
})

-- Command line completions
cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = "path" },
    { name = "cmdline" }
  })
})

-- Search completions
cmp.setup.cmdline({ "/", "?" }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = "buffer" },
    { name = "nvim_lsp_document_symbol" }
  }
})