local opts = { noremap = true, silent = true, nowait = true }

local status_ok, Job = pcall(require, 'plenary.job')
if not status_ok then
  return
end

-- Save and run this file
vim.api.nvim_create_user_command('SS', function()
  vim.cmd(':w')
  local file_path = vim.fn.expand('%')
  vim.cmd('source ' .. file_path)
  print('source file ' .. file_path)
end, {})

function P(obj)
  print(vim.inspect(obj))
end

-- Git workflow
local function git_diff(commit)
  local list = nil
  Job:new({
    command = 'git',
    args = { 'diff', commit, '--relative', '--name-only' },
    on_exit = function(job, code)
      if code == 0 then
        list = job:result()
        return
      end
      error('git diff error ' .. code)
    end
  }):sync(15000)
  return list
end

-- find a base commit and perform diff and save it to the quickfix list
local current_commit = 'origin/master'
local function create_qflist(title, list)
  local qflist = {}
  for i, v in ipairs(list) do
    qflist[i] = {
      filename = v,
      lnum = 1,
    }
  end
  local result = vim.fn.setqflist({}, ' ', {
    title = title,
    items = qflist
  })
  if result == 0 then
    vim.cmd('copen')
  else
    error('failed to set qflist with diff result' .. result)
  end
end

local function diff_specific_commit(commit)
  current_commit = commit
  local list = git_diff(commit)
  create_qflist('Diff ' .. commit, list)
end

local function find_merge_base(base)
  base = base ~= nil and base or 'origin/master'
  local commit = nil
  Job:new({
    command = 'git',
    args = { 'merge-base', base, 'h' },
    on_stdout = function(err, data)
      if err == nil and data ~= nil then
        commit = data
        return
      end
      error('git commit not found ' .. err)
    end,
  }):sync()
  return commit
end

vim.api.nvim_create_user_command('DiffCommit', function(opts)
  diff_specific_commit(opts.args)
end, { nargs = 1 })

vim.api.nvim_create_user_command('DiffBaseCommit', function(opts)
  local commit = opts.args
  local base = find_merge_base(commit)
  diff_specific_commit(base)
end, { nargs = 1 })

-- git-fugitive keymaps
local function close_all_fugitive_diff_windows()
  -- find and close fugitive diff windows
  local wins = vim.api.nvim_tabpage_list_wins(0)
  for _, win in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    local bufname = vim.api.nvim_buf_get_name(buf)
    -- Only close if it's a fugitive buffer
    if bufname:match("fugitive://") then
      -- If it's the last window, close the buffer instead
      if #wins == 1 then
        vim.api.nvim_buf_delete(buf, { force = false })
      else
        vim.api.nvim_win_close(win, false)
      end
    end
  end
end

local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")
-- Diff Quicklist stack navigation
local diff_next, diff_prev = ts_repeat_move.make_repeatable_move_pair(
  function()
    close_all_fugitive_diff_windows()
    vim.cmd("Cnext")
    vim.cmd('Gvdiffsplit! ' .. current_commit .. ':%')
  end,
  function()
    close_all_fugitive_diff_windows()
    vim.cmd("Cprev")
    vim.cmd('Gvdiffsplit! ' .. current_commit .. ':%')
  end
)

local wk = require("which-key")
wk.add({
  { "<leader>d",  group = "Diff/Debug" },
  { "<leader>dt", ':G! difftool --name-only<CR>', desc = "Difftool (working dir)", mode = "n" },
  {
    "<leader>Dt",
    function()
      local commit = vim.fn.input("Commit: ")
      current_commit = commit
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
      vim.cmd('Gvdiffsplit! ' .. current_commit .. ':%')
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
