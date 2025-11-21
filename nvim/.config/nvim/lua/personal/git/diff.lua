local M = {}

local job_runner = require('personal.job')

local ORIGIN_PREFIX = 'origin/'
local ORIGIN_STALE_THRESHOLD_SECONDS = 2 * 60 * 60
local recently_fetched_refs = {}
local current_commit = 'origin/master'

local function starts_with(str, prefix)
  if vim.startswith then
    return vim.startswith(str, prefix)
  end
  return str:sub(1, #prefix) == prefix
end

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

function M.maybe_fetch_stale_origin_branch(ref, update_message)
  if type(ref) ~= 'string' or not starts_with(ref, ORIGIN_PREFIX) then
    return
  end
  local now = os.time()
  -- We only consider fetching when the tracked commit on origin looks stale.
  local branch = string.sub(ref, #ORIGIN_PREFIX + 1)
  if branch == '' then
    return
  end
  local ok, timestamp = pcall(function()
    local result = job_runner.run({
      command = 'git',
      args = { 'log', '-1', '--format=%ct', ref },
    })
    if result[1] then
      return tonumber(result[1])
    end
    return nil
  end)
  if not ok or not timestamp then
    return
  end
  local age_seconds = os.difftime(now, timestamp)
  if age_seconds <= ORIGIN_STALE_THRESHOLD_SECONDS then
    return
  end
  -- last_fetch remains a secondary safeguard; even if the commit is old,
  -- skip the fetch when we already hit origin recently because we know
  -- that another fetch won't bring in much more new commits yet.
  local last_fetch = recently_fetched_refs[ref]
  if last_fetch and os.difftime(now, last_fetch) <= ORIGIN_STALE_THRESHOLD_SECONDS then
    return
  end
  if update_message then
    update_message('Fetching ' .. ref .. ' ...')
  end
  local tail_lines = {}
  local function append_line(line)
    if not update_message or not line or line == '' then
      return
    end
    table.insert(tail_lines, line)
    if #tail_lines > 5 then
      table.remove(tail_lines, 1)
    end
    update_message(table.concat(tail_lines, '\n'))
  end
  job_runner.run({
    command = 'git',
    args = { 'fetch', 'origin', branch },
    on_stdout = update_message and function(_, line)
      vim.schedule(function()
        append_line(line)
      end)
    end or nil,
    on_stderr = update_message and function(_, line)
      vim.schedule(function()
        append_line(line)
      end)
    end or nil,
  })
  recently_fetched_refs[ref] = now
end

return M
