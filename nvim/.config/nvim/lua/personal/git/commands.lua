local M = {}

local diff = require('personal.git.diff')
local progress = require('personal.progress')

local function register_reload_command()
  vim.api.nvim_create_user_command('SS', function()
    vim.cmd(':w')
    local file_path = vim.fn.expand('%')
    vim.cmd('source ' .. file_path)
    print('source file ' .. file_path)
  end, {})
end

local function register_inspect_helper()
  _G.P = function(obj)
    print(vim.inspect(obj))
  end
end

local function register_diff_commands()
  vim.api.nvim_create_user_command('DiffCommit', function(opts)
    local commit = opts.args
    progress.run_with_progress(function()
      diff.diff_specific_commit(commit)
    end, 'Diffing ' .. commit, 'Diff ready for ' .. commit, 'Diff failed for ' .. commit)
  end, { nargs = 1 })

  vim.api.nvim_create_user_command('DiffBaseCommit', function(opts)
    local base_ref = opts.args
    local start_target = (base_ref ~= nil and base_ref ~= '') and base_ref or 'origin/master'
    progress.run_with_progress(function(update_message)
      diff.maybe_fetch_stale_origin_branch(start_target, update_message)
      local resolved_base = diff.find_merge_base(base_ref)
      diff.diff_specific_commit(resolved_base)
      update_message('Diff ready for ' .. start_target)
    end, 'Diffing ' .. start_target, nil, 'Diff failed for ' .. start_target)
  end, { nargs = '?' })
end

function M.setup()
  register_reload_command()
  register_inspect_helper()
  register_diff_commands()
end

return M
