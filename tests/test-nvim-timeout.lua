local bootstrap = dofile(vim.env.DOTFILES_TEST_MODULE)
local async = require("vim._async")
local original_run, original_add, original_parallelism = async.run, vim.pack.add, vim.uv.available_parallelism
local timeouts = {}
local fake_run = function()
  return { wait = function(_, timeout) table.insert(timeouts, timeout) end }
end
async.run = fake_run
vim.pack.add = function()
  async.run():wait()
  async.run():wait(1234)
  assert(vim.uv.available_parallelism() <= 2)
end
bootstrap.add_plugins({})
assert(timeouts[1] == 1800000 and timeouts[2] == 1234)
assert(async.run == fake_run and vim.uv.available_parallelism == original_parallelism)
vim.pack.add = function() error("test failure") end
assert(not pcall(bootstrap.add_plugins, {}))
assert(async.run == fake_run and vim.uv.available_parallelism == original_parallelism)
async.run, vim.pack.add = original_run, original_add
