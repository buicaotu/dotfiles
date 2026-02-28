return {
  "folke/snacks.nvim",
  opts = {
    scope = {
      keys = {
        textobject = {
          is = {
            min_size = 2, -- minimum size of the scope
            edge = false, -- inner scope
            cursor = false,
            treesitter = { blocks = { enabled = false } },
            desc = "inner scope",
          },
          as = {
            cursor = false,
            min_size = 2, -- minimum size of the scope
            treesitter = { blocks = { enabled = false } },
            desc = "full scope",
          },
        },
        jump = {
          ["[s"] = {
            min_size = 1, -- allow single line scopes
            bottom = false,
            cursor = false,
            edge = true,
            treesitter = { blocks = { enabled = false } },
            desc = "jump to top edge of scope",
          },
          ["]s"] = {
            min_size = 1, -- allow single line scopes
            bottom = true,
            cursor = false,
            edge = true,
            treesitter = { blocks = { enabled = false } },
            desc = "jump to bottom edge of scope",
          },
        },
      },
    },
    bigfile = {},
    image = {},
    terminal = {
      win = {
        keys = {
          term_normal = {
            "<C-]>",
            function(self)
              vim.cmd("stopinsert")
            end,
            mode = "t",
            expr = true,
            desc = "CMD-[ to exit terminal insert mode (mapped in wezterm)",
          },
          -- term_normal = {
          --   "<esc>",
          --   function(self)
          --     self.esc_timer = self.esc_timer or (vim.uv or vim.loop).new_timer()
          --     if self.esc_timer:is_active() then
          --       self.esc_timer:stop()
          --       vim.cmd("stopinsert")
          --     else
          --       self.esc_timer:start(200, 0, function() end)
          --       return "<esc>"
          --     end
          --   end,
          --   mode = "t",
          --   expr = true,
          --   desc = "Double escape to normal mode",
          -- },
        },
      },
    },
  },
  keys = {
    { "<leader>bd", function() Snacks.bufdelete() end,                                                        desc = "Delete Buffer" },
    { "<leader>/",  function() Snacks.terminal.toggle(nil, { start_insert = true, auto_insert = false }) end, desc = "Toggle Terminal" },
  }
}
