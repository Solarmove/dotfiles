-- Run after :MasonToolsInstallSync; fail rather than silently report success.
local registry = require("mason-registry")
local missing = {}
for _, name in ipairs(assert(_G.dotfiles_mason_tools)) do
  local ok, package = pcall(registry.get_package, name)
  if not ok or not package:is_installed() then
    table.insert(missing, name)
  end
end
if #missing > 0 then
  error("Mason packages not installed: " .. table.concat(missing, ", "))
end
local system = vim.uv.os_uname()
local suffix = system.sysname == "Darwin" and (system.machine == "arm64" and "macos-arm64" or "macos") or "linux"
if system.sysname == "Darwin" or system.machine == "x86_64" then
  local root = vim.fn.stdpath("data") .. "/site/pack/core/opt/markdown-preview.nvim"
  local binary = root .. "/app/bin/markdown-preview-" .. suffix
  if vim.fn.executable(binary) ~= 1 then
    local package = vim.json.decode(table.concat(vim.fn.readfile(root .. "/package.json"), "\n"))
    local result = vim.system({ "bash", root .. "/app/install.sh", "v" .. package.version }, { text = true }):wait()
    assert(result.code == 0 and vim.fn.executable(binary) == 1, "Markdown Preview installation failed: " .. (result.stderr or ""))
  end
end
assert(vim.fn.executable("tree-sitter") == 1, "tree-sitter executable is missing")
assert(_G.dotfiles_install_parsers(), "Some Tree-sitter parsers failed to install")
