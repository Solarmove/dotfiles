-- Used by install.sh in a separate Neovim process before normal configuration loads.
local function check_tasks()
  for name, plugin in pairs(require("lazy.core.config").plugins) do
    for _, task in ipairs(plugin._.tasks or {}) do
      if task:has_errors() then
        io.stderr:write(name .. ": " .. task:output(vim.log.levels.ERROR) .. "\n")
        vim.cmd("cquit 1")
        return false
      end
    end
  end
  if vim.v.errmsg ~= "" then
    io.stderr:write(vim.v.errmsg .. "\n")
    vim.cmd("cquit 1")
    return false
  end
  return true
end
require("lazy").restore({ wait = true, show = false })
if not check_tasks() then return end
if vim.fn.executable("make") == 1 and vim.fn.executable("cc") == 1 then
  require("lazy").build({ plugins = { "telescope-fzf-native.nvim" }, wait = true, show = false })
  if not check_tasks() then return end
end
if vim.fn.executable("cc") == 1 then
  local parsers = require("nvim-treesitter.parsers")
  for _, language in ipairs({ "python", "bash", "markdown", "markdown_inline" }) do
    if not parsers.has_parser(language) then
      vim.cmd("TSInstallSync " .. language)
      if vim.v.errmsg ~= "" then
        io.stderr:write(vim.v.errmsg .. "\n")
        vim.cmd("cquit 1")
        return
      end
    end
  end
end
