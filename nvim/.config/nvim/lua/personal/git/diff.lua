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
    items = qflist,
  })
  if result == 0 then
    vim.cmd('copen')
  else
    error('failed to set qflist with diff result ' .. result)
  end
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

function M.diff_specific_commit(commit)
  M.set_current_commit(commit)
  local git_root = get_git_root()
  local list = job_runner.run({
    command = 'git',
    args = { '-C', git_root, 'diff', commit, '--name-only' },
  })
  if #list > 50 then
    local answer = vim.fn.input(#list .. ' files changed. Continue? (y/n) ')
    if answer ~= 'y' then
      return
    end
  end
  local relative_list = {}
  for i, path in ipairs(list) do
    local abs_path = git_root .. '/' .. path
    relative_list[i] = vim.fn.fnamemodify(abs_path, ':p:.')
  end
  create_qflist('Diff ' .. commit, relative_list)
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
