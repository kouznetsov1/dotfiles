local harpoon = require("harpoon")

harpoon:setup({
	settings = {
		save_on_toggle = true,
		sync_on_ui_close = true,
		key = function()
			return vim.loop.cwd()
		end,
	},
})

-- Basic keymaps
vim.keymap.set("n", "<leader>ha", function()
	harpoon:list():add()
end, { desc = "Add file to Harpoon" })
vim.keymap.set("n", "<C-h>", function()
	harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Toggle Harpoon menu" })

-- Navigate to specific files
vim.keymap.set("n", "<leader>1", function()
	harpoon:list():select(1)
end, { desc = "Harpoon file 1" })
vim.keymap.set("n", "<leader>2", function()
	harpoon:list():select(2)
end, { desc = "Harpoon file 2" })
vim.keymap.set("n", "<leader>3", function()
	harpoon:list():select(3)
end, { desc = "Harpoon file 3" })
vim.keymap.set("n", "<leader>4", function()
	harpoon:list():select(4)
end, { desc = "Harpoon file 4" })
vim.keymap.set("n", "<leader>5", function()
	harpoon:list():select(5)
end, { desc = "Harpoon file 5" })
vim.keymap.set("n", "<leader>6", function()
	harpoon:list():select(6)
end, { desc = "Harpoon file 6" })

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<C-S-P>", function()
	harpoon:list():prev()
end, { desc = "Harpoon previous" })
vim.keymap.set("n", "<C-S-N>", function()
	harpoon:list():next()
end, { desc = "Harpoon next" })

