local M = {}

local diff = require('personal.git.diff')
local progress = require('personal.progress')

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

local function register_stage_changes_command()
  -- save the index fugitive buffer i.e. staging the changes
  -- this is the same as opening a diff, using diffput then save the fugitive buffer
  -- but this command will confirm and save all fugitive buffer (! to skip confirmation)
  vim.api.nvim_create_user_command("StageChanges", function(opts)
    -- collect modified fugitive index buffers first
    local to_stage = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      local name = vim.api.nvim_buf_get_name(buf)
      if name:match("fugitive://.*//0/") and vim.bo[buf].modified then
        table.insert(to_stage, { buf = buf, file = name:match("fugitive://.*//0/(.*)") })
      end
    end

    if #to_stage == 0 then
      print("Nothing to stage")
      return
    end

    -- skip confirmation if bang
    if not opts.bang then
      local files = vim.tbl_map(function(item) return "  - " .. item.file end, to_stage)
      local prompt = "Stage these files?\n" .. table.concat(files, "\n") .. "\n[y/n]: "
      local answer = vim.fn.input(prompt)
      if answer:lower() ~= "y" then
        print("\nAborted")
        return
      end
    end

    -- write all
    local staged = {}
    for _, item in ipairs(to_stage) do
      vim.api.nvim_buf_call(item.buf, function() vim.cmd("write") end)
      table.insert(staged, item.file)
    end

    print((opts.bang and "" or "\n") .. "Staged: " .. table.concat(staged, ", "))
  end, { bang = true, desc = "Stage all fugitive index buffers" })
end

function M.setup()
  register_diff_commands()
  register_stage_changes_command()
end

return M
