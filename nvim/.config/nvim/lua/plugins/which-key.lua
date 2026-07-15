return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "modern",
    delay = 0, -- pop up immediately when summoned
    icons = {
      mappings = false,
    },
    win = {
      border = "rounded",
    },
    -- No automatic triggers: which-key never intercepts key sequences, so a
    -- partial/unmapped prefix just resolves via the normal Vim timeout instead
    -- of dropping into a which-key pending state. Summon it manually instead.
    triggers = {},
  },
  keys = {
    { "<leader>?", function() require("which-key").show() end, desc = "Which-key", mode = { "n", "x" } },
  },
  config = function(_, opts)
    local reg = require("which-key.plugins.registers")
    reg.registers =  '*+"0123456789-:.%/#=_abcdefghijklmnopqrstuvwxyz'
    local wk = require("which-key")
    wk.setup(opts)
  end,
}
