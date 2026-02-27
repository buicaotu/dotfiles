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

local wk = require("which-key")
wk.add({
  { "<leader>du", require('dapui').toggle, desc = "Toggle DAP UI", mode = "n" },
  { "<leader>de", require('dapui').eval, desc = "Eval under cursor", mode = { "n", "v" } },
  { "<leader>dw", function() require('dapui').elements.watches.add(vim.fn.expand("<cexpr>")) end, desc = "Add to watch", mode = "n" },
})
