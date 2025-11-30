local M = {}

local diff = require('personal.git.diff')
local ts_repeat_move = require('nvim-treesitter-textobjects.repeatable_move')
local wk = require('which-key')

local function is_fugitive_buf(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  return name:match('^fugitive://') ~= nil
end

local function close_all_fugitive_diff_windows()
  local wins = vim.api.nvim_tabpage_list_wins(0)
  local fugitive_bufs = {}
  -- collecting all fugitive buffers
  for _, win in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    if is_fugitive_buf(buf) then
      fugitive_bufs[buf] = true
    end
  end
  -- closing all fugitive buffers
  for buf, _ in pairs(fugitive_bufs) do
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
  end
  -- making sure alternate buffer is not fugitive
  local alt_buf = vim.fn.bufnr('#')
  if alt_buf ~= -1 and is_fugitive_buf(alt_buf) then
    pcall(vim.api.nvim_buf_delete, alt_buf, { force = true })
  end
end

local function make_diff_moves()
  local diff_move = ts_repeat_move.make_repeatable_move(function(opts)
    close_all_fugitive_diff_windows()
    if opts.forward then
      vim.cmd('Cnext')
    else
      vim.cmd('Cprev')
    end
    vim.cmd('Gvdiffsplit! ' .. diff.get_current_commit() .. ':%')
  end)
  return diff_move
end

local function register_keymaps()
  local diff_move = make_diff_moves()
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
      function() diff_move({ forward = true }) end,
      desc = "Next diff view",
      mode = { "n", "x", "o" }
    },
    {
      "[r",
      function() diff_move({ forward = false }) end,
      desc = "Previous diff view",
      mode = { "n", "x", "o" }
    },
  })
end

function M.setup()
  register_keymaps()
end

return M
