local fzf = require("fzf-lua")

-- Minimal config that works on both Linux and macOS
fzf.setup({
  files = {
    -- On Ubuntu, fd is called fdfind
    cmd = vim.fn.executable("fdfind") == 1 and "fdfind --type f --hidden --follow --exclude .git" 
          or vim.fn.executable("fd") == 1 and "fd --type f --hidden --follow --exclude .git"
          or "find . -type f -not -path '*/\\.git/*'",
  },
})