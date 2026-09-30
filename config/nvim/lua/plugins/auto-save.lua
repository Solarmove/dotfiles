return {
  "okuuva/auto-save.nvim",
  cmd = "ASToggle", -- optional for lazy loading on command
  event = { "InsertLeave", "TextChanged" }, -- trigger events
  opts = {
    execution_message = {
      enabled = false, -- hide save notifications
    },
  },
}
