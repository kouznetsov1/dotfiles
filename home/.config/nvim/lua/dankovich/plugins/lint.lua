local lint = require("lint")

-- Configure linters by filetype
lint.linters_by_ft = {
  javascript = { "eslint" },
  typescript = { "eslint" },
  javascriptreact = { "eslint" },
  typescriptreact = { "eslint" },
  python = { "ruff" },
}

-- Helper function to find eslint
local function get_eslint_command()
  -- Try to find the git root first
  local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")
  if vim.v.shell_error == 0 and git_root ~= "" then
    local eslint_path = git_root .. "/node_modules/.bin/eslint"
    if vim.fn.executable(eslint_path) == 1 then
      return eslint_path
    end
  end
  -- Try to find eslint in any parent node_modules
  local node_modules_eslint = vim.fn.findfile("node_modules/.bin/eslint", ".;")
  if node_modules_eslint ~= "" then
    return vim.fn.fnamemodify(node_modules_eslint, ":p")
  end
  -- Fallback to global eslint
  return "eslint"
end

-- Store the original ESLint linter config
local eslint = lint.linters.eslint

-- Override just the command
eslint.cmd = get_eslint_command

-- Create autocommand to trigger linting
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
  callback = function()
    -- For monorepos, find the nearest package.json to use as cwd
    local file_path = vim.api.nvim_buf_get_name(0)
    local file_dir = vim.fn.fnamemodify(file_path, ":h")
    -- Search for package.json up the directory tree
    local package_json = vim.fn.findfile("package.json", file_dir .. ";")
    local cwd = nil
    if package_json ~= "" then
      cwd = vim.fn.fnamemodify(package_json, ":h")
    end

    -- Check if this project uses Biome instead of ESLint
    local biome_config = vim.fn.findfile("biome.json", file_dir .. ";")
    if biome_config == "" then
      biome_config = vim.fn.findfile("biome.jsonc", file_dir .. ";")
    end

    -- Only run eslint if there's no biome config
    if biome_config ~= "" then
      -- Skip linting for JS/TS files in Biome projects
      local ft = vim.bo.filetype
      if ft == "javascript" or ft == "typescript" or ft == "javascriptreact" or ft == "typescriptreact" then
        return
      end
    end

    lint.try_lint(nil, { cwd = cwd })
  end,
})

-- Optional: Add a command to manually trigger linting
vim.api.nvim_create_user_command("Lint", function()
  -- For monorepos, find the nearest package.json to use as cwd
  local file_path = vim.api.nvim_buf_get_name(0)
  local file_dir = vim.fn.fnamemodify(file_path, ":h")
  -- Search for package.json up the directory tree
  local package_json = vim.fn.findfile("package.json", file_dir .. ";")
  local cwd = nil
  if package_json ~= "" then
    cwd = vim.fn.fnamemodify(package_json, ":h")
  end
  print("Linting from:", cwd or "default")
  lint.try_lint(nil, { cwd = cwd })
end, {})

