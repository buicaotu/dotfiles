local M = {}

-- Import modules
local core = require("personal.command_palette.core")
local lsp_commands = require("personal.command_palette.commands.lsp")
local workflow_commands = require("personal.command_palette.commands.workflow")

-- Re-export core functions
M.open_palette = core.open_palette
M.register_command = core.register_command

-- Setup function
function M.setup()
  -- Setup all command modules
  lsp_commands.setup()
  workflow_commands.setup()
end

return M
