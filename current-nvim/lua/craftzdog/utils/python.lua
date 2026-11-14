local M = {}
local selected = {}

function M.root(bufnr)
	bufnr = bufnr or 0
	return vim.fs.root(bufnr, {
		"pyproject.toml",
		"pyrightconfig.json",
		"setup.py",
		"setup.cfg",
		"requirements.txt",
		"pytest.ini",
		".git",
	}) or vim.fn.getcwd()
end

function M.interpreter(root)
	root = root or M.root()
	if selected[root] then
		return selected[root]
	end
	local candidates = {}
	for _, directory in ipairs({ ".venv", "venv", "env" }) do
		table.insert(candidates, vim.fs.joinpath(root, directory, "bin", "python"))
	end
	for _, name in ipairs({ "VIRTUAL_ENV", "CONDA_PREFIX" }) do
		if vim.env[name] then
			table.insert(candidates, vim.fs.joinpath(vim.env[name], "bin", "python"))
		end
	end
	for _, path in ipairs(candidates) do
		if vim.fn.executable(path) == 1 then
			return path
		end
	end
	return vim.fn.exepath("python3")
end

function M.select()
	local root = M.root()
	vim.ui.input({ prompt = "Python interpreter: ", default = M.interpreter(root), completion = "file" }, function(path)
		if not path or path == "" then
			return
		end
		path = vim.fn.fnamemodify(vim.fn.expand(path), ":p")
		if vim.fn.executable(path) ~= 1 then
			vim.notify("Python is not executable: " .. path, vim.log.levels.ERROR)
			return
		end
		selected[root] = path
		for _, client in ipairs(vim.lsp.get_clients({ name = "basedpyright" })) do
			if client.config.root_dir == root then
				client.settings.python = vim.tbl_extend("force", client.settings.python or {}, { pythonPath = path })
				client:notify("workspace/didChangeConfiguration", { settings = client.settings })
			end
		end
		vim.notify("Python: " .. path)
	end)
end

function M.run(tests, all)
	local filename = vim.api.nvim_buf_get_name(0)
	if filename == "" or vim.bo.filetype ~= "python" then
		vim.notify("Open a Python file first", vim.log.levels.WARN)
		return
	end
	vim.cmd.update()
	local root = M.root()
	local argv = { M.interpreter(root) }
	if tests then
		vim.list_extend(argv, { "-m", "pytest" })
		if not all then
			table.insert(argv, filename)
		end
	else
		table.insert(argv, filename)
	end
	vim.cmd("botright 14split")
	vim.cmd.enew()
	vim.fn.jobstart(argv, { term = true, cwd = root })
	vim.cmd.startinsert()
end

return M
