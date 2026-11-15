-- Repair interrupted vim.pack clones without deleting user data.
-- This is only used during the dotfiles installer, not normal editor startup.
local M = {}

function M.recover_incomplete_plugins()
  local lock_path = vim.fn.stdpath("config") .. "/nvim-pack-lock.json"
  local lock = vim.json.decode(table.concat(vim.fn.readfile(lock_path), "\n"))
  local root = vim.fn.stdpath("data") .. "/site/pack/core/opt"
  local backup
  for name, spec in pairs(lock.plugins) do
    assert(name ~= "." and name ~= ".." and not name:find("[/\\]"), "Invalid plugin name in lockfile")
    assert(type(spec.rev) == "string" and spec.rev:match("^[0-9a-f]+$"), "Invalid plugin revision: " .. name)
    local path = root .. "/" .. name
    if vim.uv.fs_stat(path) then
      local head = vim.system({ "git", "-C", path, "rev-parse", "--verify", "HEAD" }, { text = true }):wait()
      -- An interrupted clone can have HEAD, but the wrong revision or an empty index.
      local files = vim.system({ "git", "-C", path, "ls-files" }, { text = true }):wait()
      -- vim.pack regenerates doc/tags for some plugins; this is normal.
      local status = vim.system({ "git", "-C", path, "status", "--porcelain", "--untracked-files=no", "--", ".", ":(exclude)doc/tags" }, { text = true }):wait()
      if head.code ~= 0 or vim.trim(head.stdout or "") ~= spec.rev
        or files.code ~= 0 or (files.stdout or "") == ""
        or status.code ~= 0 or (status.stdout or "") ~= "" then
        if not backup then
          backup = vim.fn.stdpath("state") .. "/dotfiles-incomplete-plugins/" .. os.date("%Y%m%d-%H%M%S") .. "-" .. vim.fn.getpid()
          vim.fn.mkdir(backup, "p")
        end
        local ok, err = vim.uv.fs_rename(path, backup .. "/" .. name)
        assert(ok, "Could not back up incomplete plugin " .. path .. ": " .. tostring(err))
        vim.api.nvim_echo({ { "Backed up incomplete or modified plugin " .. name .. " to " .. backup } }, true, {})
      end
    end
  end
end

-- Neovim 0.12's vim.pack uses an internal 120-second default for the whole
-- parallel install. Slow disks/networks can exceed it. Temporarily extend only
-- implicit waits and limit clone concurrency; restore both functions afterwards.
function M.add_plugins(specs)
  local async = require("vim._async")
  local original_run = async.run
  local original_parallelism = vim.uv.available_parallelism
  async.run = function(...)
    local task = original_run(...)
    local original_wait = task.wait
    task.wait = function(self, timeout)
      return original_wait(self, timeout or 1800000)
    end
    return task
  end
  if original_parallelism then
    vim.uv.available_parallelism = function()
      return math.min(original_parallelism() or 1, 2)
    end
  end
  local ok, err = pcall(vim.pack.add, specs)
  async.run = original_run
  if original_parallelism then vim.uv.available_parallelism = original_parallelism end
  if not ok then error(err) end
end

return M
