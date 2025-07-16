local M = {}

-- Function to get git root directory
local function get_git_root()
  local handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
  if handle then
    local result = handle:read("*a"):gsub("\n", "")
    handle:close()
    if result ~= "" then
      return result
    end
  end
  return nil
end

-- Function to copy selection with context
function M.copy_with_context()
  -- Get visual selection range
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  local start_col = vim.fn.col("'<")
  local end_col = vim.fn.col("'>")
  
  -- Get the selected text
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  
  -- Handle partial selection on first and last lines
  if #lines > 0 then
    -- Adjust first line
    if start_col > 1 then
      lines[1] = string.sub(lines[1], start_col)
    end
    
    -- Adjust last line
    if #lines > 1 and end_col < #lines[#lines] + 1 then
      lines[#lines] = string.sub(lines[#lines], 1, end_col)
    elseif #lines == 1 and end_col < #lines[1] + 1 then
      lines[1] = string.sub(lines[1], 1, end_col - start_col + 1)
    end
  end
  
  -- Get file path
  local file_path = vim.fn.expand("%:p")
  local git_root = get_git_root()
  local relative_path
  
  if git_root then
    -- Make path relative to git root
    relative_path = file_path:sub(#git_root + 2)
  else
    -- Fall back to just the filename if not in a git repo
    relative_path = vim.fn.expand("%:t")
  end
  
  -- Format the context header for LLM
  local line_info
  if start_line == end_line then
    line_info = string.format("line %d", start_line)
  else
    line_info = string.format("lines %d-%d", start_line, end_line)
  end
  
  -- Create LLM-friendly format
  local formatted_content = string.format([[
From file: %s
Location: %s

```
%s
```]], relative_path, line_info, table.concat(lines, "\n"))
  
  -- Copy to clipboard
  vim.fn.setreg("+", formatted_content)
  
  -- Show confirmation
  vim.notify(string.format("Copied %s (%s) to clipboard", relative_path, line_info))
end

-- Function to copy diagnostics with context
function M.copy_diagnostics()
  local current_line = vim.fn.line(".")
  local bufnr = vim.api.nvim_get_current_buf()
  
  -- Get diagnostics for current line
  local diagnostics = vim.diagnostic.get(bufnr, { lnum = current_line - 1 })
  
  if #diagnostics == 0 then
    vim.notify("No diagnostics on current line")
    return
  end
  
  -- Get file path
  local file_path = vim.fn.expand("%:p")
  local git_root = get_git_root()
  local relative_path
  
  if git_root then
    relative_path = file_path:sub(#git_root + 2)
  else
    relative_path = vim.fn.expand("%:t")
  end
  
  -- Get the problematic line
  local line_content = vim.api.nvim_buf_get_lines(bufnr, current_line - 1, current_line, false)[1]
  
  -- Format diagnostics
  local diagnostic_info = {}
  for _, diagnostic in ipairs(diagnostics) do
    local severity = vim.diagnostic.severity[diagnostic.severity]
    local source = diagnostic.source or "unknown"
    table.insert(diagnostic_info, string.format("[%s] %s (%s)", severity, diagnostic.message, source))
  end
  
  -- Create LLM-friendly format
  local formatted_content = string.format([[
From file: %s
Location: line %d
Diagnostics: %s

```
%s
```

Issues:
%s]], relative_path, current_line, #diagnostics == 1 and "1 issue" or #diagnostics .. " issues", 
    line_content, table.concat(diagnostic_info, "\n"))
  
  -- Copy to clipboard
  vim.fn.setreg("+", formatted_content)
  
  -- Show confirmation
  vim.notify(string.format("Copied %d diagnostic%s from %s:%d to clipboard", 
    #diagnostics, #diagnostics == 1 and "" or "s", relative_path, current_line))
end

-- Setup function
function M.setup()
  -- Create visual mode mapping
  vim.keymap.set("v", "<leader>yc", function()
    -- Execute the copy, then return to normal mode
    vim.cmd("normal! :")  -- This ensures we capture the visual selection
    M.copy_with_context()
  end, { desc = "Yank with context (filename:lines)" })
  
  -- Create normal mode mapping for diagnostic yank
  vim.keymap.set("n", "<leader>yd", M.copy_diagnostics, { desc = "Yank diagnostics with context" })
end

return M