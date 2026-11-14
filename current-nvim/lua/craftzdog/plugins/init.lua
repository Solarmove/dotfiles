gh = function(x)
	return "https://github.com/" .. x
end

require("craftzdog.plugins.markdown")

vim.pack.add({
	-- UI
	{ src = gh("craftzdog/solarized-osaka.nvim") },
	{ src = gh("nvim-mini/mini.icons") },
	{ src = gh("folke/snacks.nvim") },
	{ src = gh("folke/trouble.nvim") },
	{ src = gh("nvim-lualine/lualine.nvim") },
	{ src = gh("b0o/incline.nvim") },
	{ src = gh("esmuellert/codediff.nvim") },
	{ src = gh("rachartier/tiny-cmdline.nvim") },
	-- Editor
	{ src = gh("jake-stewart/multicursor.nvim"), version = "1.0" },
	{ src = gh("stevearc/conform.nvim") },
	{ src = gh("nvim-treesitter/nvim-treesitter") },
	{ src = gh("mks-h/treesitter-autoinstall.nvim") },
	{ src = gh("nvim-mini/mini.pairs") },
	{ src = gh("craftzdog/mini.diff"), version = "feat/grouping" },
	{ src = gh("saghen/blink.cmp"), version = vim.version.range("^1") },
	{ src = gh("folke/todo-comments.nvim") },
	{ src = gh("lewis6991/gitsigns.nvim") },
	{ src = gh("linrongbin16/gitlinker.nvim") },
	{ src = gh("brenoprata10/nvim-highlight-colors") },
	-- LSP
	{ src = gh("neovim/nvim-lspconfig") },
	{ src = gh("mason-org/mason.nvim") },
	{ src = gh("WhoIsSethDaniel/mason-tool-installer.nvim") },
	-- Util
	{ src = gh("folke/persistence.nvim") },
	{ src = gh("iamcco/markdown-preview.nvim") },
	{ src = gh("stevearc/oil.nvim") },
	{ src = gh("zbirenbaum/copilot.lua") },
	{ src = gh("nvim-lua/plenary.nvim") },
	{ src = gh("CopilotC-Nvim/CopilotChat.nvim") },
	-- Python debugger
	{ src = gh("mfussenegger/nvim-dap") },
	{ src = gh("mfussenegger/nvim-dap-python") },
	{ src = gh("nvim-neotest/nvim-nio") },
	{ src = gh("rcarriga/nvim-dap-ui") },
})

if #vim.api.nvim_get_runtime_file("lua/craftzdog/plugins/local.lua", false) > 0 then
	require("craftzdog.plugins.local")
end

require("craftzdog.plugins.ui")
require("craftzdog.plugins.treesitter")
require("craftzdog.plugins.editor")
require("craftzdog.plugins.lsp")
require("craftzdog.plugins.util")
require("craftzdog.plugins.sessions")
require("craftzdog.plugins.keymaps")
require("craftzdog.plugins.multicursor")
require("craftzdog.plugins.python")
require("craftzdog.plugins.copilotchat")
