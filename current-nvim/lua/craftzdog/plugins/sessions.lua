local persistence = require("persistence")

vim.opt.sessionoptions = { "buffers", "curdir", "folds", "help", "tabpages", "winsize", "winpos" }
persistence.setup({ branch = false })

vim.keymap.set("n", "<leader>ss", persistence.load, { desc = "Restore project session" })
vim.keymap.set("n", "<leader>sS", persistence.select, { desc = "Select session" })
vim.keymap.set("n", "<leader>sd", persistence.stop, { desc = "Stop session saving" })

-- Headless tools and commit editors must not replace the project workspace.
if #vim.api.nvim_list_uis() == 0 or vim.env.GIT_INDEX_FILE or vim.env.GIT_EXEC_PATH then
	persistence.stop()
	return
end

local group = vim.api.nvim_create_augroup("ProjectSessions", { clear = true })
local stdin = false
vim.api.nvim_create_autocmd("StdinReadPre", {
	group = group,
	callback = function()
		stdin = true
		persistence.stop()
	end,
})

vim.api.nvim_create_autocmd("VimEnter", {
	group = group,
	once = true,
	callback = function()
		if vim.bo.filetype == "gitcommit" or vim.bo.filetype == "gitrebase" then
			persistence.stop()
			return
		end
		if vim.fn.argc() == 0 and not stdin and vim.v.this_session == "" then
			persistence.load()
		end
	end,
})
