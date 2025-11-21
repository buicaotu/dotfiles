local M = {}

local status_ok, Job = pcall(require, 'plenary.job')
if not status_ok then
  return M
end

local DEFAULT_TIMEOUT = 15000

--- Resolve timeout from opts table or fall back to default.
-- @param opts table|nil
-- @return number timeout_ms
local function resolve_timeout(opts)
  if opts and type(opts.timeout) == 'number' then
    return opts.timeout
  end
  return DEFAULT_TIMEOUT
end

--- Run a shell command using plenary.job with timeout/error handling.
-- @param opts table Command configuration for Job:new (command, args, etc.).
-- @return table stdout_lines, Job job The recorded stdout (table) and the job handle.
function M.run(opts)
  assert(type(opts) == 'table', 'opts must be a table')
  assert(type(opts.command) == 'string', 'opts.command must be provided')

  local timeout = resolve_timeout(opts)
  local job_opts = vim.tbl_extend('force', {
    enable_recording = true,
  }, opts)

  job_opts.timeout = nil

  local job = Job:new(job_opts)
  job:start()
  local ok, err = pcall(function()
    job:wait(timeout, nil, true)
  end)
  if not ok then
    job:shutdown()
    error(err)
  end
  local code = job.code or 0
  if code ~= 0 then
    local stderr_lines = job:stderr_result()
    local stderr = nil
    if stderr_lines and #stderr_lines > 0 then
      stderr = table.concat(stderr_lines, '\n')
    end
    local arg_string = table.concat(job_opts.args or {}, ' ')
    error(string.format('%s %s exited with code %d%s', job_opts.command, arg_string, code,
      stderr and (': ' .. stderr) or ''))
  end
  return job:result() or {}, job
end

return M
