-- Work monorepo root lookup
--
-- vim.g.work_repo (from .env.lua) is the main checkout. Given a path, returns
-- the top of whichever checkout it belongs to — the main one or any of its
-- git worktrees — or nil if it's outside the work repo.
local cache = {} -- checkout top -> true/false

return function(path)
  local main = vim.g.work_repo and vim.fs.normalize(vim.g.work_repo)
  if not main or not path or path == "" then
    return nil
  end
  local top = vim.fs.root(vim.fs.normalize(path), ".git")
  if not top then
    return nil
  end
  if cache[top] == nil then
    local ok = top == main
    if not ok then
      -- a worktree's .git is a file: "gitdir: <main>/.git/worktrees/<name>"
      local f = io.open(top .. "/.git")
      local line = f and f:read("*l")
      if f then f:close() end
      ok = line ~= nil and vim.startswith(line, "gitdir: " .. main .. "/.git/worktrees/")
    end
    cache[top] = ok
  end
  return cache[top] and top or nil
end
