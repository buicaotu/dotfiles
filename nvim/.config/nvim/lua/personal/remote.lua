local M = {}

--- Detect if Neovim is running as a remote UI server.
--- When a client connects via --remote-ui, there will be
--- at least one UI channel with chan > 0.
local function is_remote()
  local uis = vim.api.nvim_list_uis()
  for _, ui in ipairs(uis) do
    if ui.chan > 0 then
      return true
    end
  end
  return false
end

function M.setup()
  if not is_remote() then
    return
  end

  -- Override vim.ui.open to copy URLs to the local clipboard.
  -- vim.fn.setreg('+') routes through the --remote-ui clipboard UI extension
  -- to the local client's clipboard, which handles it with the local machine's provider.
  -- This backs: Browse/:GBrowse, gx (normal + visual), LSP code actions, etc.
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

return M
