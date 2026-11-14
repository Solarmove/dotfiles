local python = require("craftzdog.utils.python")

vim.lsp.config("basedpyright", {
	before_init = function(_, config)
		config.settings.python = vim.tbl_extend("force", config.settings.python or {}, {
			pythonPath = python.interpreter(config.root_dir),
		})
	end,
	settings = {
		basedpyright = {
			disableOrganizeImports = true,
			analysis = {
				typeCheckingMode = "basic",
				diagnosticMode = "openFilesOnly",
				autoSearchPaths = true,
				-- Ruff handles unused imports/variables; keep type checking enabled.
				diagnosticSeverityOverrides = {
					reportUnusedImport = "none",
					reportUnusedVariable = "none",
				},
			},
		},
	},
})
vim.lsp.config("ruff", {
	on_attach = function(client)
		client.server_capabilities.hoverProvider = false
	end,
})
vim.lsp.enable({ "basedpyright", "ruff" })

local dap = require("dap")
local dapui = require("dapui")
dapui.setup()
local adapter_python = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
require("dap-python").setup(adapter_python, {
	pythonPath = function()
		return python.interpreter()
	end,
})
require("dap-python").resolve_python = function()
	return python.interpreter()
end
require("dap-python").test_runner = "pytest"
for _, config in ipairs(dap.configurations.python) do
	config.cwd = function()
		return python.root()
	end
end
dap.listeners.after.event_initialized.python_ui = function()
	dapui.open()
end
dap.listeners.before.event_terminated.python_ui = function()
	dapui.close()
end
dap.listeners.before.event_exited.python_ui = function()
	dapui.close()
end

local function map(lhs, rhs, desc)
	vim.keymap.set("n", lhs, rhs, { silent = true, desc = desc })
end
map("<F5>", dap.continue, "Debug: start / continue")
map("<F10>", dap.step_over, "Debug: step over")
map("<F11>", dap.step_into, "Debug: step into")
map("<F12>", dap.step_out, "Debug: step out")
-- craftzdog already uses <leader>d as a delete operator and <leader>dv for diff.
-- Use a separate debug prefix to keep those mappings intact.
map("<leader>bb", dap.toggle_breakpoint, "Debug: toggle breakpoint")
map("<leader>bc", dap.continue, "Debug: start / continue")
map("<leader>bo", dap.step_over, "Debug: step over")
map("<leader>bi", dap.step_into, "Debug: step into")
map("<leader>bu", dapui.toggle, "Debug: toggle UI")
map("<leader>be", dap.terminate, "Debug: stop")
map("<leader>bn", function()
	require("dap-python").test_method({
		config = {
			cwd = python.root(),
			pythonPath = python.interpreter(),
		},
	})
end, "Debug: nearest Python test")
map("<leader>pr", function()
	python.run(false)
end, "Python: run file")
map("<leader>pt", function()
	python.run(true, false)
end, "Python: pytest file")
map("<leader>pT", function()
	python.run(true, true)
end, "Python: pytest project")
map("<leader>pv", python.select, "Python: select interpreter")
map("<leader>pi", function()
	vim.notify("Python: " .. python.interpreter())
end, "Python: show interpreter")
vim.api.nvim_create_user_command("PythonSelect", python.select, { desc = "Select Python interpreter for this project" })
vim.api.nvim_create_user_command("PythonInfo", function()
	vim.print(python.interpreter())
end, { desc = "Show Python interpreter" })
