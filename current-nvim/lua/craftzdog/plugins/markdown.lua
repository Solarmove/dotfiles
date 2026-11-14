vim.g.mkdp_auto_start = 0
vim.g.mkdp_auto_close = 1
vim.g.mkdp_echo_preview_url = 1

vim.api.nvim_create_autocmd("PackChanged", {
	group = vim.api.nvim_create_augroup("MarkdownPreviewBuild", { clear = true }),
	callback = function(ev)
		if ev.data.spec.name ~= "markdown-preview.nvim" then
			return
		end
		if ev.data.kind ~= "install" and ev.data.kind ~= "update" then
			return
		end
		local root = ev.data.path
		local package = vim.json.decode(table.concat(vim.fn.readfile(root .. "/package.json"), "\n"))
		local result = vim.system({ "bash", root .. "/app/install.sh", "v" .. package.version }, { text = true }):wait()
		local binary = vim.fn.has("mac") == 1 and (vim.uv.os_uname().machine == "arm64" and "macos-arm64" or "macos") or "linux"
		if result.code ~= 0 or vim.fn.executable(root .. "/app/bin/markdown-preview-" .. binary) ~= 1 then
			vim.notify("Не удалось установить Markdown Preview: " .. (result.stderr or ""), vim.log.levels.ERROR)
		end
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("MarkdownPreviewKeymaps", { clear = true }),
	pattern = "markdown",
	callback = function(ev)
		vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", {
			buffer = ev.buf,
			desc = "Markdown: предпросмотр в браузере",
		})
	end,
})
