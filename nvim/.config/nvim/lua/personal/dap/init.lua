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
  { "<F8>", dap.continue, desc = "Continue", mode = "n" },
  { "<F9>", dap.step_over, desc = "Step over", mode = "n" },
  { "<F10>", dap.step_into, desc = "Step into", mode = "n" },
  { "<F7>", dap.step_out, desc = "Step out", mode = "n" },
  { "<leader><leader>bc", dap.clear_breakpoints, desc = "Clear all breakpoints", mode = "n" },
  { "<leader><leader>bb", dap.toggle_breakpoint, desc = "Toggle breakpoint", mode = "n" },
  {
    "<leader><leader>bB",
    function()
      dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
    end,
    desc = "Conditional breakpoint",
    mode = "n",
  },
  { "<leader>br", dap.run_to_cursor, desc = "Run to cursor", mode = "n" },
})
