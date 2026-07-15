return {
  "folke/flash.nvim",
  ---@type Flash.Config
  opts = {
    modes = {
      -- disable f/F/t/T enhancement
      char = { enabled = false },
      -- disable `/` search integration
      search = { enabled = false },
    },
  },
  keys = {
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    { "gs", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
  },
}
