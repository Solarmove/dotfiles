local M = { enabled = true }
local saving = false
local errors = {}

function M.save_all()
	if not M.enabled or saving then
		return
	end
	saving = true
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) then
			local options = vim.bo[buf]
			local name = vim.api.nvim_buf_get_name(buf)
			if
				options.modified
				and options.modifiable
				and not options.readonly
				and options.buftype == ""
				and name ~= ""
				and not name:match("^%a[%w+.-]*://")
			then
				local ok, err = pcall(vim.api.nvim_buf_call, buf, function()
					vim.cmd("silent update")
				end)
				if ok then
					errors[buf] = nil
				elseif errors[buf] ~= tostring(err) then
					errors[buf] = tostring(err)
					vim.notify("Автосохранение: " .. name .. "\n" .. tostring(err), vim.log.levels.WARN)
				end
			end
		end
	end
	saving = false
end

function M.setup()
	local group = vim.api.nvim_create_augroup("CraftzdogAutoSave", { clear = true })
	vim.api.nvim_create_autocmd("ModeChanged", {
		group = group,
		pattern = { "i*:n", "R*:n" },
		callback = function()
			if not M.enabled or saving then
				return
			end
			-- Let the mode switch finish before save hooks format any buffers.
			vim.schedule(function()
				-- Fast Esc/i sequences must not format text after typing resumes.
				if vim.api.nvim_get_mode().mode == "n" then
					M.save_all()
				end
			end)
		end,
	})
	vim.api.nvim_create_user_command("AutoSaveToggle", function()
		M.enabled = not M.enabled
		vim.notify(
			"Автосохранение: "
				.. (M.enabled and "при переходе в обычный режим" or "выключено")
		)
	end, { force = true, desc = "Toggle saving when leaving Insert or Replace mode for Normal mode" })
end

return M
