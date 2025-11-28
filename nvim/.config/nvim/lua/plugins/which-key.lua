return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "modern",
    delay = 500,
    icons = {
      mappings = false,
    },
    win = {
      border = "rounded",
    },
  },
  config = function(_, opts)
    local reg = require("which-key.plugins.registers")
    reg.registers =  '*+"0123456789-:.%/#=_abcdefghijklmnopqrstuvwxyz'
    local wk = require("which-key")
    wk.setup(opts)
  end,
}
