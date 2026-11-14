local mc = require("multicursor-nvim")
mc.setup()

local map = vim.keymap.set
for _, modifier in ipairs({ "A", "C" }) do
	map("n", "<" .. modifier .. "-LeftMouse>", mc.handleMouse, { desc = "Add/remove cursor" })
	map("n", "<" .. modifier .. "-LeftDrag>", mc.handleMouseDrag)
	map("n", "<" .. modifier .. "-LeftRelease>", mc.handleMouseRelease)
end

map({ "n", "x" }, "<leader>mc", mc.toggleCursor, { desc = "Place cursor / toggle cursors" })
map({ "n", "x" }, "<leader>mn", function()
	mc.matchAddCursor(1)
end, { desc = "Add cursor at next match" })
map({ "n", "x" }, "<leader>ms", function()
	mc.matchSkipCursor(1)
end, { desc = "Skip next cursor match" })

mc.addKeymapLayer(function(set)
	set("n", "<Esc>", function()
		if not mc.cursorsEnabled() then
			mc.enableCursors()
		else
			mc.clearCursors()
		end
	end, { desc = "Enable / clear multiple cursors" })
end)

vim.api.nvim_set_hl(0, "MultiCursorCursor", { reverse = true })
vim.api.nvim_set_hl(0, "MultiCursorVisual", { link = "Visual" })
vim.api.nvim_set_hl(0, "MultiCursorDisabledCursor", { reverse = true })
vim.api.nvim_set_hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
