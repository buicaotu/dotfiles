-- fff.nvim — Rust-backed file index with its own grouped grep/file picker UI.

-- When invoked from an oil buffer, scope the picker to that buffer's
-- directory (mirrors how :Rg behaves in oil). Merges any extra opts so
-- callers can still pass grep modes etc. Returns opts unchanged elsewhere.
-- Also closes a floating oil window so the picker isn't stacked on top of it.
local function with_oil_cwd(extra)
  local opts = extra or {}
  if vim.bo.filetype == "oil" then
    local ok, oil = pcall(require, "oil")
    if ok then
      opts.cwd = oil.get_current_dir()
      if vim.api.nvim_win_get_config(0).relative ~= "" then
        oil.close()
      end
    end
  end
  return opts
end

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
    { "<leader>ff", function() require('fff').find_files(with_oil_cwd()) end, desc = 'FFFind files' },
    { "<leader>fg", function() require('fff').live_grep(with_oil_cwd()) end, desc = 'LiFFFe grep' },
    { "<leader>fz",
      function() require('fff').live_grep(with_oil_cwd({ grep = { modes = { 'fuzzy', 'plain' } } })) end,
      desc = 'Live fffuzy grep',
    },
    { "<leader>fw",
      function() require('fff').live_grep_under_cursor() end,
      mode = { 'n', 'x' },
      desc = 'Search current word / selection',
    }
  },
}
