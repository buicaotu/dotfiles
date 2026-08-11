local M = {}

local job_runner = require('personal.job')
local current_commit = 'origin/master'

local function get_git_root()
  local result = job_runner.run({
    command = 'git',
    args = { 'rev-parse', '--show-toplevel' },
  })
  if not result[1] or result[1] == '' then
    error('failed to resolve git root')
  end
  return result[1]
end

local function to_status_label(status)
  if status == 'A' then
    return 'added'
  end
  if status == 'D' then
    return 'deleted'
  end
  return 'edited'
end

local function parse_name_status(line)
  local fields = vim.split(line, '\t', { plain = true, trimempty = true })
  local status = fields[1]
  local path = fields[#fields]
  if not status or not path then
    return nil
  end
  return {
    path = path,
    label = to_status_label(status:sub(1, 1)),
  }
end

local function create_qflist(title, list)
  local qflist = {}
  for i, v in ipairs(list) do
    qflist[i] = {
      filename = v.filename,
      lnum = 1,
      text = '[' .. v.label .. ']',
    }
  end
  local result = vim.fn.setqflist({}, ' ', {
    title = title,
    items = qflist,
  })
  if result == 0 then
    vim.cmd('copen')
  else
    error('failed to set qflist with diff result ' .. result)
  end
end

local function get_changed_files(git_root, commit)
  local args = { '-C', git_root, 'diff', '--name-status' }
  if commit and commit ~= '' then
    table.insert(args, commit)
  end

  local list = job_runner.run({
    command = 'git',
    args = args,
  })

  local changes = {}
  for _, line in ipairs(list) do
    local entry = parse_name_status(line)
    if entry then
      table.insert(changes, {
        filename = vim.fn.fnamemodify(git_root .. '/' .. entry.path, ':p:.'),
        label = entry.label,
      })
    end
  end
  return changes
end

local function confirm_large_diff(list)
  if #list <= 50 then
    return true
  end

  local answer = vim.fn.input(#list .. ' files changed. Continue? (y/n) ')
  return answer == 'y'
end

function M.set_current_commit(commit)
  if commit == nil or commit == '' then
    current_commit = commit or ''
    return
  end
  current_commit = commit
end

function M.get_current_commit()
  return current_commit
end

function M.diff_working_tree()
  M.set_current_commit('')
  local git_root = get_git_root()
  local list = get_changed_files(git_root)
  if not confirm_large_diff(list) then
    return
  end
  create_qflist('Diff working tree', list)
end

function M.diff_specific_commit(commit)
  M.set_current_commit(commit)
  local git_root = get_git_root()
  local list = get_changed_files(git_root, commit)
  if not confirm_large_diff(list) then
    return
  end
  create_qflist('Diff ' .. commit, list)
end

function M.find_merge_base(base)
  base = (base ~= nil and base ~= '') and base or 'origin/master'
  local result = job_runner.run({
    command = 'git',
    args = { 'merge-base', base, '@' },
  })
  if not result[1] then
    error('git merge-base returned no result')
  end
  return result[1]
end

return M
