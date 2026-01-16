-- PR Review Mode
-- <leader>rr = start review, <leader>rq = quit review
-- <leader>rs = toggle seen, <leader>rd = toggle diff split
-- <leader>rn/rp = next/prev file, <leader>rf = focus file list

local M = {}

-- State
local state = {
  active = false,
  files = {},        -- { path, hash, seen }
  sidebar_buf = nil,
  sidebar_win = nil,
  current_idx = 1,
  diff_split = false,
  diff_win = nil,
}

local config = {
  base_branch = "main",
  panel_height = 10,
  state_file = ".git/review-state",
}

-- Helpers
local function get_git_root()
  local root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")
  return root ~= "" and root or nil
end

local function get_file_hash(filepath)
  local root = get_git_root()
  if not root then return nil end
  local full = root .. "/" .. filepath
  local hash = vim.fn.system("git hash-object " .. vim.fn.shellescape(full) .. " 2>/dev/null"):gsub("\n", "")
  return hash ~= "" and hash or nil
end

local function file_exists_in_base(filepath)
  local result = vim.fn.system("git cat-file -e " .. config.base_branch .. ":" .. vim.fn.shellescape(filepath) .. " 2>/dev/null")
  return vim.v.shell_error == 0
end

local function get_first_changed_line(filepath)
  -- Parse diff output to find first changed line
  local diff = vim.fn.system("git diff " .. config.base_branch .. " -- " .. vim.fn.shellescape(filepath) .. " 2>/dev/null")
  -- Look for @@ -old,len +new,len @@ pattern
  local line = diff:match("@@ %-%d+,?%d* %+(%d+)")
  return tonumber(line) or 1
end

local function get_changed_files()
  local root = get_git_root()
  if not root then return {} end

  -- Get file stats (+/- lines)
  local stats = {}
  local numstat = vim.fn.system("git diff --numstat " .. config.base_branch .. " 2>/dev/null")
  for line in numstat:gmatch("[^\r\n]+") do
    local added, removed, path = line:match("(%d+)%s+(%d+)%s+(.+)")
    if path then
      stats[path] = { added = tonumber(added) or 0, removed = tonumber(removed) or 0 }
    end
  end

  local output = vim.fn.system("git diff --name-only " .. config.base_branch .. " 2>/dev/null")
  local files = {}
  for line in output:gmatch("[^\r\n]+") do
    if line ~= "" then
      local is_new = not file_exists_in_base(line)
      local stat = stats[line] or { added = 0, removed = 0 }
      table.insert(files, {
        path = line,
        hash = get_file_hash(line),
        seen = false,
        is_new = is_new,
        added = stat.added,
        removed = stat.removed,
      })
    end
  end
  return files
end

-- Persistence
local function get_state_path()
  local root = get_git_root()
  return root and (root .. "/" .. config.state_file) or nil
end

local function load_state()
  local path = get_state_path()
  if not path then return {} end
  local f = io.open(path, "r")
  if not f then return {} end
  local content = f:read("*a")
  f:close()
  local ok, data = pcall(vim.fn.json_decode, content)
  return ok and data or {}
end

local function save_state()
  local path = get_state_path()
  if not path then return end
  local data = {}
  for _, file in ipairs(state.files) do
    if file.seen then
      data[file.path] = file.hash
    end
  end
  local f = io.open(path, "w")
  if f then
    f:write(vim.fn.json_encode(data))
    f:close()
  end
end

local function apply_saved_state()
  local saved = load_state()
  for _, file in ipairs(state.files) do
    local saved_hash = saved[file.path]
    -- Only mark seen if hash matches (file unchanged since review)
    if saved_hash and saved_hash == file.hash then
      file.seen = true
    end
  end
end

-- Panel rendering (bottom)
local function render_panel()
  if not state.sidebar_buf or not vim.api.nvim_buf_is_valid(state.sidebar_buf) then return end

  local seen_count = 0
  for _, f in ipairs(state.files) do
    if f.seen then seen_count = seen_count + 1 end
  end

  local lines = {
    " Review vs " .. config.base_branch .. "  │  " .. seen_count .. "/" .. #state.files .. " reviewed  │  j/k:nav  Enter:open  s:seen  q:quit  <leader>rd:diff",
    ""
  }

  -- Track stats positions for highlighting
  local highlights = {}
  for i, file in ipairs(state.files) do
    local prefix = i == state.current_idx and " ▶ " or "   "
    local check = file.seen and "✓ " or "  "
    local status = file.is_new and "[N] " or "[M] "
    local base = prefix .. check .. status .. file.path .. "  "
    local add_str = "+" .. file.added
    local del_str = " -" .. file.removed
    table.insert(lines, base .. add_str .. del_str)

    -- Store highlight positions (line is 0-indexed for nvim_buf_add_highlight)
    local line_idx = #lines - 1
    local add_start = #base
    local add_end = add_start + #add_str
    local del_start = add_end
    local del_end = del_start + #del_str
    table.insert(highlights, { line = line_idx, add_start = add_start, add_end = add_end, del_start = del_start, del_end = del_end })
  end

  vim.api.nvim_buf_set_option(state.sidebar_buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(state.sidebar_buf, 0, -1, false, lines)

  -- Apply highlights
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(state.sidebar_buf, -1, "ReviewStatsAdd", hl.line, hl.add_start, hl.add_end)
    vim.api.nvim_buf_add_highlight(state.sidebar_buf, -1, "ReviewStatsDel", hl.line, hl.del_start, hl.del_end)
  end

  vim.api.nvim_buf_set_option(state.sidebar_buf, "modifiable", false)
end

-- Panel creation (bottom)
local function create_panel()
  -- Create buffer
  state.sidebar_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(state.sidebar_buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(state.sidebar_buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(state.sidebar_buf, "filetype", "review")

  -- Create window at bottom
  vim.cmd("botright " .. config.panel_height .. "split")
  state.sidebar_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(state.sidebar_win, state.sidebar_buf)

  -- Window options
  vim.api.nvim_win_set_option(state.sidebar_win, "number", false)
  vim.api.nvim_win_set_option(state.sidebar_win, "relativenumber", false)
  vim.api.nvim_win_set_option(state.sidebar_win, "signcolumn", "no")
  vim.api.nvim_win_set_option(state.sidebar_win, "winfixheight", true)
  vim.api.nvim_win_set_option(state.sidebar_win, "cursorline", true)

  -- Panel keymaps
  local opts = { buffer = state.sidebar_buf, silent = true }
  vim.keymap.set("n", "<CR>", function()
    M.open_file(state.current_idx)
    -- Return focus to panel
    if state.sidebar_win and vim.api.nvim_win_is_valid(state.sidebar_win) then
      vim.api.nvim_set_current_win(state.sidebar_win)
    end
  end, opts)
  vim.keymap.set("n", "j", function() M.select_file(state.current_idx + 1) end, opts)
  vim.keymap.set("n", "k", function() M.select_file(state.current_idx - 1) end, opts)
  vim.keymap.set("n", "<C-d>", function() M.select_file(state.current_idx + 5) end, opts)
  vim.keymap.set("n", "<C-u>", function() M.select_file(state.current_idx - 5) end, opts)
  vim.keymap.set("n", "G", function() M.select_file(#state.files) end, opts)
  vim.keymap.set("n", "gg", function() M.select_file(1) end, opts)
  vim.keymap.set("n", "s", function() M.toggle_seen(state.current_idx) end, opts)
  vim.keymap.set("n", "q", M.stop, opts)

  render_panel()
end

local function close_sidebar()
  if state.sidebar_win and vim.api.nvim_win_is_valid(state.sidebar_win) then
    vim.api.nvim_win_close(state.sidebar_win, true)
  end
  state.sidebar_win = nil
  state.sidebar_buf = nil
end

-- Diff split
local function open_diff_split(filepath)
  if state.diff_win and vim.api.nvim_win_is_valid(state.diff_win) then
    vim.api.nvim_win_close(state.diff_win, true)
  end

  local root = get_git_root()
  if not root then return end

  -- Get main version content (need to quote the whole ref:path)
  local git_ref = config.base_branch .. ":" .. filepath
  local content = vim.fn.system("git show " .. vim.fn.shellescape(git_ref) .. " 2>/dev/null")
  if vim.v.shell_error ~= 0 then
    -- File is new, no diff to show
    vim.notify("File is new (not in " .. config.base_branch .. ")", vim.log.levels.INFO)
    return
  end

  -- Create diff buffer
  local diff_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(diff_buf, 0, -1, false, vim.split(content, "\n"))
  vim.api.nvim_buf_set_option(diff_buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(diff_buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(diff_buf, "modifiable", false)

  -- Set filetype for syntax highlighting
  local ft = vim.filetype.match({ filename = filepath })
  if ft then
    vim.api.nvim_buf_set_option(diff_buf, "filetype", ft)
  end

  -- Open in vertical split
  vim.cmd("leftabove vsplit")
  state.diff_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(state.diff_win, diff_buf)
  vim.api.nvim_buf_set_name(diff_buf, config.base_branch .. ":" .. filepath)

  -- Left (base) window: no line numbers
  vim.api.nvim_win_set_option(state.diff_win, "number", false)
  vim.api.nvim_win_set_option(state.diff_win, "relativenumber", false)
  vim.api.nvim_win_set_option(state.diff_win, "signcolumn", "no")

  -- Enable diff mode on left
  vim.cmd("diffthis")

  -- Move to right (editable) window
  vim.cmd("wincmd l")

  -- Right window: line numbers on
  vim.wo.number = true
  vim.wo.relativenumber = false
  vim.wo.signcolumn = "yes"

  -- Enable diff mode on right
  vim.cmd("diffthis")
end

local function close_diff_split()
  if state.diff_win and vim.api.nvim_win_is_valid(state.diff_win) then
    vim.api.nvim_win_close(state.diff_win, true)
  end
  state.diff_win = nil
  vim.cmd("diffoff!")
end

-- Public API
function M.start()
  if state.active then
    vim.notify("Review already active", vim.log.levels.WARN)
    return
  end

  local root = get_git_root()
  if not root then
    vim.notify("Not in a git repository", vim.log.levels.ERROR)
    return
  end

  state.files = get_changed_files()
  if #state.files == 0 then
    vim.notify("No changes vs " .. config.base_branch, vim.log.levels.INFO)
    return
  end

  apply_saved_state()
  state.active = true
  state.current_idx = 1
  state.diff_split = true  -- Diff view on by default

  -- Change gitsigns base to main
  vim.cmd("Gitsigns change_base " .. config.base_branch .. " true")

  create_panel()
  vim.cmd("wincmd k") -- Focus main area (above panel)

  -- Open first file
  M.open_file(1)

  vim.notify("Review started: " .. #state.files .. " files", vim.log.levels.INFO)
end

function M.stop()
  if not state.active then return end

  save_state()
  close_diff_split()
  close_sidebar()

  -- Reset gitsigns base
  vim.cmd("Gitsigns reset_base true")

  state.active = false
  state.files = {}
  state.current_idx = 1

  vim.notify("Review ended", vim.log.levels.INFO)
end

function M.select_file(idx)
  if not state.active or #state.files == 0 then return end
  state.current_idx = math.max(1, math.min(idx, #state.files))
  render_panel()

  -- Move cursor to follow selection (line = header lines + current index)
  if state.sidebar_win and vim.api.nvim_win_is_valid(state.sidebar_win) then
    local line = 2 + state.current_idx  -- 2 header lines + file index
    vim.api.nvim_win_set_cursor(state.sidebar_win, { line, 0 })
  end
end

function M.open_file(idx)
  if not state.active or #state.files == 0 then return end
  state.current_idx = math.max(1, math.min(idx, #state.files))

  local file = state.files[state.current_idx]
  local root = get_git_root()
  local full_path = root .. "/" .. file.path

  -- Close existing diff split if open
  close_diff_split()

  -- Find or create main editing window (not sidebar, not diff)
  local main_win = nil
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if win ~= state.sidebar_win and win ~= state.diff_win then
      main_win = win
      break
    end
  end

  if main_win then
    vim.api.nvim_set_current_win(main_win)
  end

  vim.cmd("edit " .. vim.fn.fnameescape(full_path))

  -- Ensure line numbers in main editing window
  vim.wo.number = true
  vim.wo.relativenumber = false

  -- Reopen diff split if was enabled
  if state.diff_split then
    open_diff_split(file.path)
  end

  -- Jump to first changed line
  local first_change = get_first_changed_line(file.path)
  vim.cmd("normal! " .. first_change .. "Gzz")

  -- Sync diff view scroll position
  if state.diff_win and vim.api.nvim_win_is_valid(state.diff_win) then
    vim.cmd("wincmd h")  -- Go to diff window
    vim.cmd("normal! " .. first_change .. "Gzz")
    vim.cmd("wincmd l")  -- Back to editing window
  end

  render_panel()
end

function M.toggle_seen(idx)
  if not state.active then return end
  idx = idx or state.current_idx
  if idx < 1 or idx > #state.files then return end

  local file = state.files[idx]
  file.seen = not file.seen
  -- Update hash when marking as seen
  if file.seen then
    file.hash = get_file_hash(file.path)
  end

  save_state()
  render_panel()
end

function M.toggle_diff_split()
  if not state.active then return end

  state.diff_split = not state.diff_split

  if state.diff_split then
    local file = state.files[state.current_idx]
    if file then
      open_diff_split(file.path)
    end
  else
    close_diff_split()
  end
end

function M.next_file()
  if state.current_idx < #state.files then
    M.open_file(state.current_idx + 1)
  end
end

function M.prev_file()
  if state.current_idx > 1 then
    M.open_file(state.current_idx - 1)
  end
end

function M.focus_sidebar()
  if state.sidebar_win and vim.api.nvim_win_is_valid(state.sidebar_win) then
    vim.api.nvim_set_current_win(state.sidebar_win)
  end
end

-- Setup keymaps
local function setup_keymaps()
  local opts = { silent = true }
  vim.keymap.set("n", "<leader>rr", M.start, vim.tbl_extend("force", opts, { desc = "Start review" }))
  vim.keymap.set("n", "<leader>rq", M.stop, vim.tbl_extend("force", opts, { desc = "Quit review" }))
  vim.keymap.set("n", "<leader>rs", function() M.toggle_seen() end, vim.tbl_extend("force", opts, { desc = "Toggle seen" }))
  vim.keymap.set("n", "<leader>rd", M.toggle_diff_split, vim.tbl_extend("force", opts, { desc = "Toggle diff split" }))
  vim.keymap.set("n", "<leader>rn", M.next_file, vim.tbl_extend("force", opts, { desc = "Next review file" }))
  vim.keymap.set("n", "<leader>rp", M.prev_file, vim.tbl_extend("force", opts, { desc = "Prev review file" }))
  vim.keymap.set("n", "<leader>rf", M.focus_sidebar, vim.tbl_extend("force", opts, { desc = "Focus review sidebar" }))
  -- Fold toggles for diff view
  vim.keymap.set("n", "<Tab>", "za", vim.tbl_extend("force", opts, { desc = "Toggle fold" }))
  vim.keymap.set("n", "<leader>ro", "zR", vim.tbl_extend("force", opts, { desc = "Open all folds" }))
  vim.keymap.set("n", "<leader>rc", "zM", vim.tbl_extend("force", opts, { desc = "Close all folds" }))
end

setup_keymaps()

-- Highlights
local function setup_highlights()
  -- Diff colors (high contrast)
  vim.api.nvim_set_hl(0, "DiffAdd", { bg = "#1e4a2e" })
  vim.api.nvim_set_hl(0, "DiffText", { bg = "#2d6a4e", bold = true })
  vim.api.nvim_set_hl(0, "DiffDelete", { bg = "#5a2020", fg = "#8a5050" })
  vim.api.nvim_set_hl(0, "DiffChange", { bg = "#3d3520" })

  -- File stats colors
  vim.api.nvim_set_hl(0, "ReviewStatsAdd", { fg = "#a6e3a1" })  -- green
  vim.api.nvim_set_hl(0, "ReviewStatsDel", { fg = "#f38ba8" })  -- red
end

setup_highlights()

return M
