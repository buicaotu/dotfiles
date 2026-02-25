local status_ok, dap = pcall(require, "dap")
if not status_ok then
	return
end

local js_debug_server = vim.fn.expand("~/.local/share/nvim/lazy/vscode-js-debug/out/src/vsDebugServer.js")

for _, adapter_type in ipairs({ "pwa-node", "pwa-chrome" }) do
  dap.adapters[adapter_type] = {
    type = "server",
    host = "localhost",
    port = "${port}",
    executable = {
      command = "node",
      args = { js_debug_server, "${port}" },
    },
  }
end

-- "javascript" 
for _, language in ipairs({ "typescript" }) do
  dap.configurations[language] = {
    {
      type = "pwa-node",
      request = "launch",
      name = "Debug Jest Tests - " .. language,
      -- trace = true, -- include debugger info
      runtimeExecutable = "node",
      runtimeArgs = {
        "./node_modules/jest/bin/jest.js",
        "--runInBand",
        "--",
        "${file}"
      },
      rootPath = "${workspaceFolder}",
      cwd = "${workspaceFolder}",
      console = "integratedTerminal",
      internalConsoleOptions = "neverOpen",
    },
    {
      -- type = "pwa-node",
      type = "pwa-chrome",
      request = "attach",
      name = "Attach",
      -- processId = require 'dap.utils'.pick_process,
      processId = function()
        return require 'dap.utils'.pick_process({
          filter = function (args)
            if string.find(args.name, 'chrome') then
              return true
            end
            return false
          end
        })
      end,
      cwd = "${workspaceFolder}",
    },
    -- {
    --   type = "pwa-chrome",
    --   request = "launch",
    --   name = "Start Chrome with \"localhost\"",
    --   url = "http://localhost:3000",
    --   webRoot = "${workspaceFolder}",
    --   userDataDir = "${workspaceFolder}/.vscode/vscode-chrome-debug-userdatadir"
    -- },
    {
      name = "Launch page proxy mode - " .. language,
      request = "launch",
      type = "pwa-chrome",
      url = "http://localhost:9090/",
      webRoot = "${workspaceFolder}",
      -- sourceMapPathOverrides = {
      -- }
    },
    {
      name = "Launch page fake mode - " .. language,
      request = "launch",
      type = "pwa-chrome",
      url = function ()
        return "http://localhost:9090/src/pages/" .. vim.fn.input('which page to launch?')
      end,
      webRoot = "${workspaceFolder}",
      -- sourceMapPathOverrides = {
      -- }
    },
    {
      name = "Debug integration test - " .. language,
      type = "pwa-node",
      request = "launch",
      runtimeExecutable = "yarn",
      runtimeArgs = function ()
        return {
          "test:integration",
          -- "${input:pagePicker}",
          vim.fn.input('Which page? '),
          -- "${input:browserPicker}",
          vim.fn.input('Which browser? '),
          "${relativeFile}",
          "--show",
          "true",
        }
      end,
      -- runtimeArgs = {
      --   "test:integration",
      --   "${input:pagePicker}",
      --   "${input:browserPicker}",
      --   "${relativeFile}",
      --   "--show",
      --   "true"
      -- },
      autoAttachChildProcesses = true,
      env = {
        CUCUMBER_TEST_RUNNER = "codeceptjs",
        -- DEBUG = "codeceptjs* pw:api"
      },
      port = 9229,
      skipFiles = {
        "<node_internals>/**"
      }
    }
  }
end
