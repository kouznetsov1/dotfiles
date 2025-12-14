local npairs = require("nvim-autopairs")
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
local cmp = require("cmp")

npairs.setup({
  check_ts = true, -- Use treesitter to check for pairs
  ts_config = {
    lua = { "string" }, -- Don't add pairs in lua strings
    javascript = { "template_string" }, -- Don't add pairs in JS template strings
  },
})

-- Make autopairs work with nvim-cmp
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())