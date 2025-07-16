-- Custom function to get path relative to git root
local function get_path_from_git_root()
  -- Check if we're in an oil buffer
  if vim.bo.filetype == 'oil' then
    -- Get the directory oil is showing
    local ok, oil = pcall(require, 'oil')
    if ok then
      local current_dir = oil.get_current_dir()
      if current_dir then
        -- Get git root for this directory
        local git_root = vim.fn.system('cd ' .. vim.fn.shellescape(current_dir) .. ' && git rev-parse --show-toplevel 2>/dev/null'):gsub('\n', '')
        
        if vim.v.shell_error ~= 0 or git_root == '' then
          -- Not in a git repo, return basename of directory
          return vim.fn.fnamemodify(current_dir, ':t')
        end
        
        -- Make path relative to git root
        local relative_path = current_dir:gsub('^' .. vim.pesc(git_root) .. '/?', '')
        if relative_path == '' then
          return '.' -- We're at the git root
        end
        return relative_path
      end
    end
  end
  
  -- Regular file handling
  local filepath = vim.fn.expand('%:p')
  if filepath == '' then
    return ''
  end
  
  -- Get git root directory for the file's directory
  local file_dir = vim.fn.fnamemodify(filepath, ':h')
  local git_root = vim.fn.system('cd ' .. vim.fn.shellescape(file_dir) .. ' && git rev-parse --show-toplevel 2>/dev/null'):gsub('\n', '')
  
  if vim.v.shell_error ~= 0 or git_root == '' then
    -- Not in a git repo, return just the filename
    return vim.fn.expand('%:t')
  end
  
  -- Make path relative to git root
  local relative_path = filepath:gsub('^' .. vim.pesc(git_root) .. '/', '')
  return relative_path
end

require('lualine').setup({
  options = {
    theme = 'gruvbox',
    icons_enabled = true,
    component_separators = { left = '|', right = '|' },
    section_separators = { left = '', right = '' },
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = { get_path_from_git_root },
    lualine_x = { 'encoding', 'fileformat', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' }
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { 'filename' },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {}
  },
})