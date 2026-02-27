local status_ok, dap = pcall(require, "dap")
if not status_ok then
	return
end

for _, adapter_type in ipairs({ "node", "chrome" }) do
  local pwa_type = "pwa-" .. adapter_type
  dap.adapters[pwa_type] = {
    type = "server",
    host = "localhost",
    port = "${port}",
    executable = {
      command = "node",
      args = {
        vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
        "${port}"
      },
    },
  }
  -- this allow us to handle launch.json configurations
  -- which specify type as "node" or "chrome" or "msedge"
  dap.adapters[adapter_type] = function(cb, config)
    local nativeAdapter = dap.adapters[pwa_type]

    config.type = pwa_type

    if type(nativeAdapter) == "function" then
      nativeAdapter(cb, config)
    else
      cb(nativeAdapter)
    end
  end
end
-- "javascript" 
for _, language in ipairs({ "typescript" }) do
  dap.configurations[language] = {
    {
      type = "pwa-chrome",
      request = "attach",
      name = "Attach",
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
