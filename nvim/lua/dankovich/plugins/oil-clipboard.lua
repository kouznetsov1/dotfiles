local M = {}

-- Store marked files
M.marked_files = {}

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

-- Toggle mark on current file
function M.toggle_mark()
  local oil = require("oil")
  local entry = oil.get_cursor_entry()
  
  if not entry then
    vim.notify("No file under cursor")
    return
  end
  
  local current_dir = oil.get_current_dir()
  local full_path = current_dir .. entry.name
  
  -- Toggle mark
  if M.marked_files[full_path] then
    M.marked_files[full_path] = nil
    vim.notify("Unmarked: " .. entry.name)
  else
    M.marked_files[full_path] = true
    vim.notify("Marked: " .. entry.name)
  end
  
  -- Move to next line for convenience
  vim.cmd("normal! j")
end

-- Clear all marks
function M.clear_marks()
  local count = vim.tbl_count(M.marked_files)
  M.marked_files = {}
  vim.notify("Cleared " .. count .. " marked files")
end

-- Copy marked files to clipboard with context
function M.copy_marked_with_context()
  local count = vim.tbl_count(M.marked_files)
  
  if count == 0 then
    vim.notify("No files marked")
    return
  end
  
  local git_root = get_git_root()
  local files = {}
  
  for path, _ in pairs(M.marked_files) do
    local display_path = path
    
    -- Make path relative to git root if in a git repo
    if git_root and vim.startswith(path, git_root) then
      display_path = path:sub(#git_root + 2)
    end
    
    table.insert(files, display_path)
  end
  
  -- Sort files for consistent output
  table.sort(files)
  
  -- Create LLM-friendly format similar to clipboard-context
  local formatted_content = string.format([[
Selected files: %d file%s
Location: %s

Files:
%s]], count, count > 1 and "s" or "", git_root or vim.fn.getcwd(), table.concat(files, "\n"))
  
  -- Copy to clipboard
  vim.fn.setreg("+", formatted_content)
  
  -- Show confirmation
  vim.notify("Copied " .. count .. " file path" .. (count > 1 and "s" or "") .. " with context to clipboard")
end

-- Copy current file path with context
function M.copy_current_with_context()
  local oil = require("oil")
  local entry = oil.get_cursor_entry()
  
  if not entry then
    vim.notify("No file under cursor")
    return
  end
  
  local current_dir = oil.get_current_dir()
  local full_path = current_dir .. entry.name
  local git_root = get_git_root()
  local display_path = full_path
  
  -- Make path relative to git root if in a git repo
  if git_root and vim.startswith(full_path, git_root) then
    display_path = full_path:sub(#git_root + 2)
  end
  
  -- Determine if it's a directory
  local file_type = entry.type == "directory" and "directory" or "file"
  
  -- Create LLM-friendly format
  local formatted_content = string.format([[
Selected %s: %s
Location: %s]], file_type, display_path, git_root or vim.fn.getcwd())
  
  -- Copy to clipboard
  vim.fn.setreg("+", formatted_content)
  
  -- Show confirmation
  vim.notify("Copied " .. file_type .. " path with context: " .. display_path)
end

-- Show marked files
function M.show_marked()
  local count = vim.tbl_count(M.marked_files)
  
  if count == 0 then
    vim.notify("No files marked")
    return
  end
  
  local git_root = get_git_root()
  local files = {}
  
  for path, _ in pairs(M.marked_files) do
    local display_path = path
    if git_root and vim.startswith(path, git_root) then
      display_path = path:sub(#git_root + 2)
    end
    table.insert(files, display_path)
  end
  
  table.sort(files)
  
  vim.notify("Marked files (" .. count .. "):\n" .. table.concat(files, "\n"))
end

return M