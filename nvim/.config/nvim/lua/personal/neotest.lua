local status_ok, neotest = pcall(require, "neotest")
if not status_ok then
  return
end

neotest.setup({
  adapters = {
    -- require("neotest-python")({
    --   dap = { justMyCode = false },
    -- }),
    -- require("neotest-plenary"),
    -- require("neotest-vim-test")({
    --   ignore_file_types = { "python", "vim", "lua" },
    -- }),
    require('neotest-jest')({
      jestCommand = "npm test --",
      -- jestConfigFile = "custom.jest.config.ts",
      -- env = { CI = true },
      cwd = function(path)
        return vim.fn.getcwd()
      end,
    }),
  },
})


-- Open test window
function open_test_window()
  neotest.output.open({ enter = true })
end

-- Run the nearest test
function run_nearest_test()
  neotest.run.run()
end
--
-- Run all tests in file
function run_current_file()
  neotest.run.run(vim.fn.expand("%"))
end

local wk = require("which-key")
local jest_debug = require("personal.jest-debug")
wk.add({
  { "<leader>t", group = "Test" },
  { "<leader>to", ':lua open_test_window()<CR>', desc = "Open test output", mode = "n" },
  { "<leader>tt", ':lua run_nearest_test()<CR>', desc = "Run nearest test", mode = "n" },
  { "<leader>ta", ':lua run_current_file()<CR>', desc = "Run all tests in file", mode = "n" },
  { "<leader>td", jest_debug.debug_nearest, desc = "Debug nearest test", mode = "n" },
})


