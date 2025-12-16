local conditions = require("heirline.conditions")
local utils = require("heirline.utils")

-- Catppuccin Macchiato colors
local colors = {
	bg = "#24273a",
	fg = "#cad3f5",
	red = "#ed8796",
	green = "#a6da95",
	yellow = "#eed49f",
	blue = "#8aadf4",
	magenta = "#c6a0f6",
	cyan = "#8bd5ca",
	orange = "#f5a97f",
	surface0 = "#363a4f",
	surface1 = "#494d64",
	overlay0 = "#6e738d",
	subtext0 = "#a5adcb",
}

require("heirline").load_colors(colors)

-- Get path relative to git root (with oil support)
local function get_path_from_git_root()
	if vim.bo.filetype == "oil" then
		local ok, oil = pcall(require, "oil")
		if ok then
			local current_dir = oil.get_current_dir()
			if current_dir then
				local git_root = vim.fn
					.system("cd " .. vim.fn.shellescape(current_dir) .. " && git rev-parse --show-toplevel 2>/dev/null")
					:gsub("\n", "")
				if vim.v.shell_error ~= 0 or git_root == "" then
					return vim.fn.fnamemodify(current_dir, ":t")
				end
				local relative_path = current_dir:gsub("^" .. vim.pesc(git_root) .. "/?", "")
				return relative_path == "" and "." or relative_path
			end
		end
	end

	local filepath = vim.fn.expand("%:p")
	if filepath == "" then
		return "[No Name]"
	end

	local file_dir = vim.fn.fnamemodify(filepath, ":h")
	local git_root = vim.fn
		.system("cd " .. vim.fn.shellescape(file_dir) .. " && git rev-parse --show-toplevel 2>/dev/null")
		:gsub("\n", "")

	if vim.v.shell_error ~= 0 or git_root == "" then
		return vim.fn.expand("%:t")
	end

	return filepath:gsub("^" .. vim.pesc(git_root) .. "/", "")
end

-- Vi Mode
local ViMode = {
	init = function(self)
		self.mode = vim.fn.mode(1)
	end,
	static = {
		mode_names = {
			n = "NORMAL",
			no = "O-PENDING",
			nov = "O-PENDING",
			noV = "O-PENDING",
			["no\22"] = "O-PENDING",
			niI = "NORMAL",
			niR = "NORMAL",
			niV = "NORMAL",
			nt = "NORMAL",
			v = "VISUAL",
			vs = "VISUAL",
			V = "V-LINE",
			Vs = "V-LINE",
			["\22"] = "V-BLOCK",
			["\22s"] = "V-BLOCK",
			s = "SELECT",
			S = "S-LINE",
			["\19"] = "S-BLOCK",
			i = "INSERT",
			ic = "INSERT",
			ix = "INSERT",
			R = "REPLACE",
			Rc = "REPLACE",
			Rx = "REPLACE",
			Rv = "V-REPLACE",
			Rvc = "V-REPLACE",
			Rvx = "V-REPLACE",
			c = "COMMAND",
			cv = "EX",
			r = "REPLACE",
			rm = "MORE",
			["r?"] = "CONFIRM",
			["!"] = "SHELL",
			t = "TERMINAL",
		},
		mode_colors = {
			n = "blue",
			i = "green",
			v = "magenta",
			V = "magenta",
			["\22"] = "magenta",
			c = "orange",
			s = "cyan",
			S = "cyan",
			["\19"] = "cyan",
			R = "red",
			r = "red",
			["!"] = "red",
			t = "yellow",
		},
	},
	provider = function(self)
		return " " .. self.mode_names[self.mode] .. " "
	end,
	hl = function(self)
		local mode = self.mode:sub(1, 1)
		return { fg = "bg", bg = self.mode_colors[mode] or "blue", bold = true }
	end,
	update = { "ModeChanged", pattern = "*:*", callback = vim.schedule_wrap(function() vim.cmd("redrawstatus") end) },
}

-- Separator after mode
local ModeSep = {
	provider = "",
	hl = function()
		local mode = vim.fn.mode(1):sub(1, 1)
		local mode_colors = {
			n = "blue", i = "green", v = "magenta", V = "magenta",
			["\22"] = "magenta", c = "orange", s = "cyan", S = "cyan",
			["\19"] = "cyan", R = "red", r = "red", ["!"] = "red", t = "yellow",
		}
		return { fg = mode_colors[mode] or "blue", bg = "surface0" }
	end,
}

-- Git Branch
local Git = {
	condition = conditions.is_git_repo,
	init = function(self)
		self.status_dict = vim.b.gitsigns_status_dict or {}
	end,
	hl = { fg = "fg", bg = "surface0" },
	{
		provider = function(self)
			return "  " .. (self.status_dict.head or "")
		end,
		hl = { fg = "orange", bold = true },
	},
	{
		provider = function(self)
			local count = self.status_dict.added or 0
			return count > 0 and (" +" .. count) or ""
		end,
		hl = { fg = "green" },
	},
	{
		provider = function(self)
			local count = self.status_dict.changed or 0
			return count > 0 and (" ~" .. count) or ""
		end,
		hl = { fg = "yellow" },
	},
	{
		provider = function(self)
			local count = self.status_dict.removed or 0
			return count > 0 and (" -" .. count) or ""
		end,
		hl = { fg = "red" },
	},
	{ provider = " " },
}

-- Diagnostics
local Diagnostics = {
	condition = conditions.has_diagnostics,
	init = function(self)
		self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
		self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
		self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
		self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
	end,
	update = { "DiagnosticChanged", "BufEnter" },
	hl = { bg = "surface0" },
	{
		provider = function(self)
			return self.errors > 0 and (" " .. self.errors .. " ") or ""
		end,
		hl = { fg = "red" },
	},
	{
		provider = function(self)
			return self.warnings > 0 and (" " .. self.warnings .. " ") or ""
		end,
		hl = { fg = "yellow" },
	},
	{
		provider = function(self)
			return self.hints > 0 and ("󰌵 " .. self.hints .. " ") or ""
		end,
		hl = { fg = "cyan" },
	},
	{
		provider = function(self)
			return self.info > 0 and (" " .. self.info .. " ") or ""
		end,
		hl = { fg = "blue" },
	},
}

-- Separator
local Sep = {
	provider = " │ ",
	hl = { fg = "overlay0", bg = "surface0" },
}

-- File path
local FileName = {
	init = function(self)
		self.filepath = get_path_from_git_root()
	end,
	hl = { fg = "fg", bg = "surface0" },
	{
		provider = function(self)
			local modified = vim.bo.modified and " ●" or ""
			return " " .. self.filepath .. modified .. " "
		end,
		hl = function()
			if vim.bo.modified then
				return { fg = "yellow", bg = "surface0" }
			end
			return { fg = "fg", bg = "surface0" }
		end,
	},
}

-- Align (pushes everything after to the right)
local Align = { provider = "%=", hl = { bg = "bg" } }

-- File encoding
local FileEncoding = {
	provider = function()
		local enc = (vim.bo.fenc ~= "" and vim.bo.fenc) or vim.o.enc
		return " " .. enc:upper() .. " "
	end,
	hl = { fg = "subtext0", bg = "surface0" },
}

-- File format
local FileFormat = {
	provider = function()
		local fmt = vim.bo.fileformat
		local icons = { unix = "LF", dos = "CRLF", mac = "CR" }
		return (icons[fmt] or fmt) .. " "
	end,
	hl = { fg = "subtext0", bg = "surface0" },
}

-- File type
local FileType = {
	provider = function()
		return vim.bo.filetype ~= "" and vim.bo.filetype or "no ft"
	end,
	hl = { fg = "cyan", bg = "surface0", bold = true },
}

-- Progress
local Progress = {
	provider = " %3p%% ",
	hl = { fg = "fg", bg = "surface0" },
}

-- Location (line:col)
local Location = {
	provider = " %3l:%-2c ",
	hl = { fg = "bg", bg = "blue", bold = true },
}

-- Location separator
local LocationSep = {
	provider = "",
	hl = { fg = "blue", bg = "surface0" },
}

-- Inactive statusline
local InactiveStatusline = {
	condition = conditions.is_not_active,
	hl = { fg = "overlay0", bg = "bg" },
	{ provider = " %f " },
	Align,
	{ provider = " %l:%c " },
}

-- Active statusline
local ActiveStatusline = {
	condition = conditions.is_active,
	ViMode,
	ModeSep,
	Git,
	Diagnostics,
	Sep,
	FileName,
	Align,
	FileEncoding,
	FileFormat,
	FileType,
	Progress,
	LocationSep,
	Location,
}

-- Final statusline
local StatusLine = {
	fallthrough = false,
	InactiveStatusline,
	ActiveStatusline,
}

require("heirline").setup({
	statusline = StatusLine,
})
