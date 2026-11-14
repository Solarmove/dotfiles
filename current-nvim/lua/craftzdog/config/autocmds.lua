-- Basic autocommands
local augroup = vim.api.nvim_create_augroup("UserConfig", {})

-- Turn off paste mode when leaving insert
vim.api.nvim_create_autocmd("InsertLeave", {
	group = augroup,
	pattern = "*",
	command = "set nopaste",
})

-- Highlight the current line on only the active buffer
local cursorline_group = vim.api.nvim_create_augroup("CursorLine", { clear = true })
vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "BufWinEnter" }, {
	group = cursorline_group,
	pattern = "*",
	command = "setlocal cursorline",
})
vim.api.nvim_create_autocmd("WinLeave", {
	group = cursorline_group,
	pattern = "*",
	command = "setlocal nocursorline",
})

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup,
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Custom filetypes
vim.filetype.add({
	extension = {
		mjml = "html",
	},
})

require("craftzdog.config.autosave").setup()
require("craftzdog.config.lsp_diagnostics").setup()

-- scrolloff alone does not preserve the bottom margin at the end of a file.
vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufWinEnter", "WinEnter", "WinResized", "VimResized" }, {
	group = vim.api.nvim_create_augroup("BottomScrollMargin", { clear = true }),
	callback = function()
		if vim.bo.buftype ~= "" or vim.api.nvim_win_get_config(0).relative ~= "" then
			return
		end
		local height = vim.api.nvim_win_get_height(0)
		local margin = math.min(10, height - 1)
		local overflow = vim.fn.winline() - (height - margin)
		if overflow > 0 then
			vim.cmd("normal! " .. overflow .. "\005")
		end
	end,
})
