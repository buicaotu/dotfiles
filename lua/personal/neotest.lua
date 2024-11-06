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
--
--
-- ~/.local/share/nvim/site/pack/packer/start

vim.api.nvim_set_keymap('n', '<leader>to', ':lua open_test_window()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>tt', ':lua run_nearest_test()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ta', ':lua run_current_file()<CR>', { noremap = true, silent = true })
