require("mason").setup()
local tools = {
		"basedpyright",
		"ruff",
		"debugpy",
		"tree-sitter-cli",
		"lua-language-server",
		"prettier",
		"prettierd",
		"selene",
		"shellcheck",
		"shfmt",
		"stylua",
		"eslint-lsp",
		"oxlint",
		"oxfmt",
		"tailwindcss-language-server",
		"vtsls",
		"copilot-language-server",
		"rust-analyzer",
}
require("mason-tool-installer").setup({
	ensure_installed = tools,
	auto_update = false,
	run_on_start = vim.env.DOTFILES_NVIM_INSTALL ~= "1",
})
if vim.env.DOTFILES_NVIM_INSTALL == "1" then
	_G.dotfiles_mason_tools = tools
end

local capabilities = {
	workspace = {
		fileOperations = {
			didRename = true,
			willRename = true,
		},
	},
}
vim.lsp.config("*", {
	capabilities = require("blink.cmp").get_lsp_capabilities(capabilities),
})

vim.lsp.enable({
	"eslint",
	"oxlint",
	"lua_ls",
	"cssls",
	"vtsls",
	"tailwindcss",
	"glsl_analyzer",
	"rust_analyzer",
})
