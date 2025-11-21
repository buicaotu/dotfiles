local M = {}

local diff = require('personal.git.diff')
local ts_repeat_move = require('nvim-treesitter.textobjects.repeatable_move')
local wk = require('which-key')

local function close_all_fugitive_diff_windows()
  local wins = vim.api.nvim_tabpage_list_wins(0)
  for _, win in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    local bufname = vim.api.nvim_buf_get_name(buf)
    if bufname:match('fugitive://') then
      if #wins == 1 then
        vim.api.nvim_buf_delete(buf, { force = false })
      else
        vim.api.nvim_win_close(win, false)
      end
    end
  end
end

local function make_diff_moves()
  local diff_next, diff_prev = ts_repeat_move.make_repeatable_move_pair(
    function()
      close_all_fugitive_diff_windows()
      vim.cmd('Cnext')
      vim.cmd('Gvdiffsplit! ' .. diff.get_current_commit() .. ':%')
    end,
    function()
      close_all_fugitive_diff_windows()
      vim.cmd('Cprev')
      vim.cmd('Gvdiffsplit! ' .. diff.get_current_commit() .. ':%')
    end
  )
  return diff_next, diff_prev
end

local function register_keymaps()
  local diff_next, diff_prev = make_diff_moves()
  wk.add({
    { "<leader>d",  group = "Diff/Debug" },
    { "<leader>dt", ':G! difftool --name-only<CR>', desc = "Difftool (working dir)", mode = "n" },
    {
      "<leader>Dt",
      function()
        local commit = vim.fn.input("Commit: ")
        diff.set_current_commit(commit)
        if commit ~= "" then
          vim.cmd('G! difftool --name-only ' .. commit)
        end
      end,
      desc = "Difftool (specific commit)",
      mode = "n",
    },
    {
      "<leader>dm",
      ':DiffBaseCommit origin/master<CR>',
      desc = "Diff master",
      mode = "n"
    },
    {
      "<leader>ds",
      function()
        vim.cmd("Gvdiffsplit!")
      end,
      desc = "Diff split (working dir)",
      mode = "n",
    },
    {
      "<leader>dS",
      function()
        vim.cmd("Gvdiffsplit! @")
      end,
      desc = "Diff split (@)",
      mode = "n",
    },
    {
      "<leader>DS",
      function()
        local commit = vim.fn.input("Commit: ")
        if commit ~= "" then
          vim.cmd('Gvdiffsplit! ' .. commit)
        end
      end,
      desc = "Diff split (specific commit)",
      mode = "n",
    },
    {
      "<leader>dg",
      function()
        vim.cmd('Gvdiffsplit! ' .. diff.get_current_commit() .. ':%')
      end,
      desc = "Diff split (stored commit)",
      mode = "n",
    },
    { "<leader>dc", close_all_fugitive_diff_windows, desc = "Close fugitive diff windows", mode = "n" },
    { "<leader>m",  group = "Merge" },
    { "<leader>mt", ':G mergetool <CR>',             desc = "Git mergetool",               mode = "n" },
    {
      "]r",
      diff_next,
      desc = "Next diff view",
      mode = { "n", "x", "o" }
    },
    {
      "[r",
      diff_prev,
      desc = "Previous diff view",
      mode = { "n", "x", "o" }
    },
  })
end

function M.setup()
  register_keymaps()
end

return M
