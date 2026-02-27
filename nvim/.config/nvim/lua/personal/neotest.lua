local status_ok, neotest = pcall(require, "neotest")
if not status_ok then
  return
end

neotest.setup({
  discovery = {
    enabled = false,
  },
  adapters = {
    require('neotest-jest')({
      cwd = function(path)
        return vim.fn.getcwd()
      end,
      isTestFile = function(file_path)
        if not file_path then return false end
        if file_path:match("%.tests%.tsx?$") then return true end
        local util = require("neotest-jest.util")
        return util.defaultTestFileMatcher(file_path)
      end,
      strategy_config = function(default_config)
        if not default_config or not default_config.runtimeExecutable then
          return default_config
        end
        local bin = default_config.runtimeExecutable
        local node_modules = bin:match("(.+)/%.bin/jest$")
        local jest_js = node_modules and (node_modules .. "/jest/bin/jest.js") or bin
        if not vim.uv.fs_stat(jest_js) then
          jest_js = vim.uv.fs_realpath(bin) or bin
        end
        local runtime_args = { jest_js, "--runInBand", "--watchAll=false" }
        if default_config.args then
          vim.list_extend(runtime_args, default_config.args)
        end
        return {
          name = default_config.name,
          type = default_config.type,
          request = default_config.request,
          runtimeExecutable = "node",
          runtimeArgs = runtime_args,
          console = default_config.console,
          internalConsoleOptions = default_config.internalConsoleOptions,
          rootPath = default_config.rootPath,
          cwd = default_config.cwd,
          trace = true,
        }
      end,
    }),
  },
})

local wk = require("which-key")
wk.add({
  { "<leader>t", group = "Test" },
  { "<leader>ts", function() neotest.summary.toggle() end, desc = "Toggle test summary", mode = "n" },
  { "<leader>to", function() neotest.output.open({ enter = true }) end, desc = "Open test output", mode = "n" },
  { "<leader>tt", function() neotest.run.run() end, desc = "Run nearest test", mode = "n" },
  { "<leader>ta", function() neotest.run.run(vim.fn.expand("%")) end, desc = "Run all tests in file", mode = "n" },
  { "<leader>td", function() neotest.run.run({ strategy = "dap" }) end, desc = "Debug nearest test", mode = "n" },
})
