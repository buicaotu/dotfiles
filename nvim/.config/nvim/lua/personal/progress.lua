local M = {}

local fidget_ok, fidget_progress = pcall(require, 'fidget.progress')

local TITLE = 'Task'

local function notify_failure(err)
  local msg = type(err) == 'string' and err or vim.inspect(err)
  vim.notify(msg, vim.log.levels.ERROR, { title = TITLE })
end

--- Create a display wrapper that manages fidget handle or vim.notify fallback.
-- @return table Table with ensure_handle/update/finish helpers.
local function create_display()
  local handle = nil
  local notif = nil

  local function ensure_handle(initial_message, level)
    if handle or notif then
      return
    end
    local message = initial_message or 'Running task...'
    local lvl = level or vim.log.levels.INFO
    if fidget_ok then
      handle = fidget_progress.handle.create({
        title = TITLE,
        message = message,
        lsp_client = { name = 'local-helper' },
      })
    else
      notif = vim.notify(message, lvl, { title = TITLE })
    end
  end

  local function update(message, level)
    if not message then
      return
    end
    local lvl = level or vim.log.levels.INFO
    if handle then
      handle.message = message
      return
    end
    if notif then
      notif = vim.notify(message, lvl, { title = TITLE, replace = notif })
      return
    end
    ensure_handle(message, lvl)
  end

  local function finish(success, message)
    local lvl = success and vim.log.levels.INFO or vim.log.levels.ERROR
    if handle then
      if message then
        handle.message = message
      end
      handle:finish()
      handle = nil
      return
    end
    if notif then
      if message then
        notif = vim.notify(message, lvl, { title = TITLE, replace = notif })
      end
      notif = nil
      return
    end
    if message then
      vim.notify(message, lvl, { title = TITLE })
    end
  end

  return {
    ensure_handle = ensure_handle,
    update = update,
    finish = finish,
  }
end

--- Validate that a message is a string or nil.
-- @param msg string|nil
-- @param label string
local function validate_message(msg, label)
  if msg ~= nil and type(msg) ~= 'string' then
    error(string.format('%s must be a string or nil', label))
  end
end

--- Run a synchronous task while showing a progress indicator.
-- @param runner function The function to execute; receives an update callback.
-- @param start_message string|nil Initial message (nil = no indicator until updated).
-- @param success_message string|nil Message shown on success.
-- @param failure_message string|nil Message shown on failure.
function M.run_with_progress(runner, start_message, success_message, failure_message)
  assert(type(runner) == 'function', 'runner must be a function')
  validate_message(start_message, 'start_message')
  validate_message(success_message, 'success_message')
  validate_message(failure_message, 'failure_message')

  local display = create_display()
  if start_message then
    display.ensure_handle(start_message, vim.log.levels.INFO)
  end

  local function update_message(message)
    display.update(message, vim.log.levels.INFO)
  end

  vim.schedule(function()
    local ok, err = pcall(runner, update_message)
    if ok then
      display.finish(true, success_message)
      return
    end

    notify_failure(err)
    display.finish(false, failure_message)
  end)
end

return M
