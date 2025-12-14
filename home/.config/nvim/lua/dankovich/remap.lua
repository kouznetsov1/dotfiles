vim.g.mapleader = " "

vim.keymap.set("n", "<leader>pv", function()
	local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")
	if git_root ~= "" then
		require("oil").open(git_root)
	else
		vim.cmd("Oil")
	end
end, { desc = "Open file explorer at git root" })

-- fzf
vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<CR>", { desc = "Fuzzy find files" })
vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep<CR>", { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers<CR>", { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", "<cmd>FzfLua help_tags<CR>", { desc = "Help tags" })
vim.keymap.set("n", "<leader>fo", "<cmd>FzfLua oldfiles<CR>", { desc = "Recent files" })
vim.keymap.set("n", "<leader>fc", "<cmd>FzfLua grep_cword<CR>", { desc = "Grep word under cursor" })

-- Lazygit
vim.keymap.set("n", "<leader>gg", function()
	vim.cmd("silent !tmux new-window lazygit")
end, { desc = "Open lazygit" })
