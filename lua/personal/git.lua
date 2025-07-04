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
local function find_merge_base(base_branch)
  base_branch = base_branch ~= nil and base_branch or 'master'
  local commit = nil
  Job:new({
    command = 'git',
    args = { 'merge-base', 'origin/' .. base_branch, 'h' },
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

local function diff_branch(base_branch)
  local commit = find_merge_base(base_branch)
  current_commit = commit
  local list = git_diff(current_commit)
  create_qflist('Diff ' .. base_branch, list)
end

local function diff_specific_commit(commit)
  current_commit = commit
  local list = git_diff(commit)
  create_qflist('Diff ' .. commit, list)
end

local function diff_branch_factory(base_branch)
  return function()
    diff_branch(base_branch)
  end
end

vim.api.nvim_create_user_command('DiffCommit', function(opts)
  diff_specific_commit(opts.args)
end, { nargs = 1 })
vim.api.nvim_create_user_command('DiffGreen', diff_branch_factory('green'), {})
vim.api.nvim_create_user_command('DiffMaster', diff_branch_factory('master'), {})


-- git-fugitive keymaps

-- difftool against current working directory
vim.keymap.set("n", "<leader>dt", ':G! difftool --name-only<CR>', opts)
-- difftool against a specific commit and store the commit
vim.keymap.set("n", "<leader>Dt", function()
  local commit = vim.fn.input("Commit: ")
  current_commit = commit
  if commit ~= "" then
    vim.cmd('G! difftool --name-only ' .. commit)
  end
end, opts)
vim.keymap.set("n", "<leader>dG", ':DiffGreen<CR>', opts)

-- diff against current working directory
vim.keymap.set("n", "<leader>ds", vim.cmd.Gvdiffsplit, opts)
vim.keymap.set("n", "<leader>dS", function()
  vim.cmd('Gvdiffsplit @')
end, opts)
-- diff against a specific commit
vim.keymap.set("n", "<leader>DS", function()
  local commit = vim.fn.input("Commit: ")
  if commit ~= "" then
    vim.cmd('Gvdiffsplit ' .. commit)
  end
end, opts)
-- diff against the stored commit from (Dt)
vim.keymap.set('n', '<leader>dg', function()
  vim.cmd('Gvdiffsplit ' .. current_commit .. ':%')
end, opts)

vim.keymap.set("n", "<leader>mt", ':G mergetool <CR>', opts)
