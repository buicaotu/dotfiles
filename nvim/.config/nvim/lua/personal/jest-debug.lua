local M = {}

local function get_call_name(call_node)
  local func = call_node:field("function")[1]
  if not func then return nil end
  if func:type() == "identifier" then
    return vim.treesitter.get_node_text(func, 0)
  end
  if func:type() == "member_expression" then
    local obj = func:field("object")[1]
    if obj then return vim.treesitter.get_node_text(obj, 0) end
  end
  return nil
end

local function get_first_string_arg(call_node)
  local args = call_node:field("arguments")[1]
  if not args then return nil end
  for child in args:iter_children() do
    local t = child:type()
    if t == "string" or t == "template_string" then
      local text = vim.treesitter.get_node_text(child, 0)
      return text:gsub("^['\"`]", ""):gsub("['\"`]$", "")
    end
  end
  return nil
end

local function get_jest_test_name_at_cursor()
  local node = vim.treesitter.get_node()
  if not node then return nil end

  local names = {}
  local found_test = false
  local current = node

  while current do
    if current:type() == "call_expression" then
      local name = get_call_name(current)
      if name == "it" or name == "test" then
        if not found_test then
          found_test = true
          local arg = get_first_string_arg(current)
          if arg then table.insert(names, 1, arg) end
        end
      elseif name == "describe" then
        local arg = get_first_string_arg(current)
        if arg then table.insert(names, 1, arg) end
      end
    end
    current = current:parent()
  end

  if #names == 0 then return nil end
  return table.concat(names, " ")
end

local function escape_jest_regex(s)
  return s:gsub("([%(%)%[%]%{%}%.%*%+%?%^%$%|\\])", "\\%1")
end

function M.debug_nearest()
  local test_name = get_jest_test_name_at_cursor()
  if not test_name then
    vim.notify("No test found at cursor", vim.log.levels.WARN)
    return
  end

  local dap = require("dap")
  local file = vim.fn.expand("%:p")
  local pattern = escape_jest_regex(test_name) .. "$"

  vim.notify("Debugging: " .. test_name)
  dap.run({
    type = "pwa-node",
    request = "launch",
    name = "Debug Nearest Jest Test",
    trace = true, -- include debugger info
    runtimeExecutable = "node",
    runtimeArgs = {
      "../node_modules/jest/bin/jest.js",
      "--runInBand",
      "--watchAll=false",
      "--testNamePattern",
      pattern,
      "--runTestsByPath",
      file,
    },
    rootPath = "${workspaceFolder}",
    cwd = "${workspaceFolder}",
    console = "integratedTerminal",
    internalConsoleOptions = "neverOpen",
  })
end

return M
