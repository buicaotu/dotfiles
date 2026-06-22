local status_ok, dapui = pcall(require, "dapui")
if not status_ok then
	return
end

dapui.setup();

local dap = require"dap"
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open({})
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close({})
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close({})
end

local cmd = vim.api.nvim_create_user_command

cmd("DapUiToggle", function()
  require("dapui").toggle()
end, { desc = "Toggle DAP UI" })

cmd("DapUiEval", function()
  require("dapui").eval()
end, { range = true, desc = "Eval expression under cursor / selection" })

cmd("DapUiWatch", function()
  require("dapui").elements.watches.add(vim.fn.expand("<cexpr>"))
end, { desc = "Add expression under cursor to watches" })
