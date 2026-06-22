local status_ok, dap = pcall(require, "dap")
if not status_ok then
	return
end

require "personal.dap.ui"
-- Setup adapters
require "personal.dap.adapters.js"

-- keymaps (F keys only; everything else is exposed as a user command)
local wk = require("which-key")
wk.add({
  { "<F8>", dap.continue, desc = "Continue", mode = "n" },
  { "<F9>", dap.step_over, desc = "Step over", mode = "n" },
  { "<F10>", dap.step_into, desc = "Step into", mode = "n" },
  { "<F7>", dap.step_out, desc = "Step out", mode = "n" },
  { "<F5>", dap.toggle_breakpoint, desc = "Toggle breakpoint", mode = "n" },
})

-- User commands.
-- Note: nvim-dap already ships :DapContinue, :DapStepOver/Into/Out,
-- :DapToggleBreakpoint, :DapClearBreakpoints, :DapTerminate, :DapEval, etc.
-- so we only add commands for the actions that lack a built-in.
local cmd = vim.api.nvim_create_user_command

cmd("DapBreakpointCondition", function()
  dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Set a conditional breakpoint" })

cmd("DapRunToCursor", dap.run_to_cursor, { desc = "Run to cursor" })

-- "Undo" the step-through: move the execution point to the cursor line
-- without running the code in between (DAP `goto`/set-next-statement).
-- Requires adapter support (capabilities.supportsGotoTargetsRequest).
cmd("DapGotoCursor", function()
  dap.goto_()
end, { desc = "Move execution point to cursor line" })
