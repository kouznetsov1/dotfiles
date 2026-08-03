local M = {}

local function git_ref_exists(ref)
	vim.fn.system({ "git", "rev-parse", "--verify", "--quiet", ref })
	return vim.v.shell_error == 0
end

local function review_base()
	if git_ref_exists("origin/main") then
		return "origin/main"
	end

	return "main"
end

function M.setup()
	require("diffview").setup({
		enhanced_diff_hl = true,
	})
end

function M.open_review()
	vim.cmd("DiffviewOpen " .. review_base())
end

return M
