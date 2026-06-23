local M = {}

local commands = require('personal.git.commands')
local keymaps = require('personal.git.keymaps')
local diff_highlight = require('personal.git.diff_highlight')

commands.setup()
keymaps.setup()
diff_highlight.setup()

return M
