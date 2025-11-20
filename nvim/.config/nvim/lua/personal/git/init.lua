local M = {}

local commands = require('personal.git.commands')
local keymaps = require('personal.git.keymaps')

commands.setup()
keymaps.setup()

return M
