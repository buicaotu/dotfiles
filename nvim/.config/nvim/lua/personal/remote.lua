local M = {}

local function is_ssh()
  return vim.env.SSH_CONNECTION ~= nil or vim.env.SSH_TTY ~= nil
end

local function is_remote_server()
  return os.getenv("NVIM_REMOTE") ~= nil
end

local function is_headless()
  for _, arg in ipairs(vim.v.argv) do
    if arg == '--headless' then
      return true
    end
  end
  return false
end

local function override_ui_open()
  local original_open = vim.ui.open
  vim.ui.open = function(path, opt)
    opt = opt or {}
    if not opt.cmd then
      vim.fn.setreg('+', path)
      vim.notify("URL copied to clipboard: " .. path, vim.log.levels.INFO)
      return nil, nil
    end
    return original_open(path, opt)
  end
end

local function setup_detach_remaps()
  vim.cmd([[
    function! s:solely_in_cmd(command)
      return (getcmdtype() == ':' && getcmdline() ==# a:command)
    endfunction
    cnoreabbrev <expr> q <SID>solely_in_cmd('q') ? 'detach' : 'q'
    cnoreabbrev <expr> qa <SID>solely_in_cmd('qa') ? 'detach' : 'qa'
  ]])
  vim.api.nvim_create_user_command('Qa', function()
    vim.cmd('detach')
  end, { force = true })
end

function M.setup()
  if is_headless() then
    setup_detach_remaps()
  end

  if is_remote_server() then
    vim.notify('Remote UI', vim.log.levels.INFO)
    override_ui_open()
  elseif is_ssh() then
    vim.notify('Remote (SSH)', vim.log.levels.INFO)
    override_ui_open()
  end
end

return M
