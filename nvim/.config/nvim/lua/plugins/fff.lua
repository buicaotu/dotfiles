-- fff.nvim — Rust-backed file index with its own grouped grep/file picker UI.
return {
  "dmtrKovalenko/fff.nvim",
  build = function()
    require("fff.download").download_or_build_binary()
  end,
  lazy = false, -- keep the index warm so :RR is instant
  opts = {
    layout = {
      -- fzf-lua style: prompt on top, best match first (top-down) instead of
      -- the default bottom prompt that renders results in reverse.
      prompt_position = "top",
    },
    keymaps = {
      -- Navigate the result list with Ctrl-j/k (fzf-style), arrows still work.
      move_down = { "<Down>", "<C-j>" },
      move_up = { "<Up>", "<C-k>" },
      -- Open the selected result (these already match the fzf-lua defaults):
      select = "<CR>",        -- open in current window
      select_split = "<C-s>", -- open in a horizontal split
      select_vsplit = "<C-v>", -- open in a vertical split
      select_tab = "<C-t>",   -- open in a new tab
    },
  },
  config = function(_, opts)
    require("fff").setup(opts)

    vim.api.nvim_create_user_command("RR", function()
      require("fff").live_grep()
    end, { desc = "fff live content grep (native grouped UI)" })
    vim.api.nvim_create_user_command("RT", function()
      require("fff").find_files()
    end, { desc = "fff find files" })
  end,
  keys = {
    { "<leader>ff", function() require('fff').find_files() end, desc = 'FFFind files' },
    { "<leader>fg", function() require('fff').live_grep() end, desc = 'LiFFFe grep' },
    { "<leader>fz",
      function() require('fff').live_grep({ grep = { modes = { 'fuzzy', 'plain' } } }) end,
      desc = 'Live fffuzy grep',
    },
    { "<leader>fw",
      function() require('fff').live_grep_under_cursor() end,
      mode = { 'n', 'x' },
      desc = 'Search current word / selection',
    }
  },
}
