local M = {}

function M.clear_stopped_clients()
	for namespace, info in pairs(vim.diagnostic.get_namespaces()) do
		local client_id = info.name:match("^nvim%.lsp%.[^.]+%.(%d+)")
		if client_id and not vim.lsp.get_client_by_id(tonumber(client_id)) then
			vim.diagnostic.reset(namespace)
		end
	end
end

function M.setup()
	local group = vim.api.nvim_create_augroup("LspDiagnosticCleanup", { clear = true })
	vim.api.nvim_create_autocmd("LspDetach", {
		group = group,
		callback = function(event)
			-- Neovim 0.12 also creates namespaces for individual diagnostic sources.
			for namespace, info in pairs(vim.diagnostic.get_namespaces()) do
				local client_id = info.name:match("^nvim%.lsp%.[^.]+%.(%d+)")
				if tonumber(client_id) == event.data.client_id then
					vim.diagnostic.reset(namespace, event.buf)
				end
			end
		end,
	})
	vim.api.nvim_create_autocmd("LspAttach", {
		group = group,
		callback = M.clear_stopped_clients,
	})
	M.clear_stopped_clients()
end

return M
