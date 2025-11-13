local status_ok, dap = pcall(require, "dap")
if not status_ok then
	return
end

require "personal.dap.ui"
-- Setup adapters
require "personal.dap.adapters.js"

-- keymaps
local wk = require("which-key")
wk.add({
  { "<F5>", dap.continue, desc = "Continue", mode = "n" },
  { "<F10>", dap.step_over, desc = "Step over", mode = "n" },
  { "<F12>", dap.step_into, desc = "Step into", mode = "n" },
  { "<F9>", dap.toggle_breakpoint, desc = "Toggle breakpoint", mode = "n" },
  {
    "<leader><leader>b",
    function()
      dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
    end,
    desc = "Conditional breakpoint",
    mode = "n",
  },
})
