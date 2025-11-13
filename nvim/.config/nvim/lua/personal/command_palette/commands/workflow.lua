local M = {}
local core = require("personal.command_palette.core")

-- Register commands
function M.setup()
  core.register_command("workflow: diff commit", function()
    local commit = vim.fn.input("Commit/Branch: ")
    commit = commit ~= "" and commit or "@"
    vim.cmd(":DiffCommit " .. commit)
  end)

  -- Session management commands
  core.register_command("workflow: save session", function()
    local cwd = vim.fn.getcwd()
    local session_file = cwd .. "/.session.vim"

    vim.cmd("mksession! " .. session_file)
    vim.notify("Session saved in project directory", vim.log.levels.INFO)
  end)

  core.register_command("workflow: load session", function()
    local cwd = vim.fn.getcwd()
    local session_file = cwd .. "/.session.vim"

    if vim.fn.filereadable(session_file) == 1 then
      vim.cmd("source " .. session_file)
      vim.notify("Session loaded from project directory", vim.log.levels.INFO)
    else
      vim.notify("No session file found in project directory", vim.log.levels.WARN)
    end
  end)

  -- Add more workflow commands as needed
end

return M
