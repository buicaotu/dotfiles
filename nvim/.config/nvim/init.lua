local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load work configuration from Lua file
local work_config_path = vim.fn.stdpath("config") .. "/.work-config.lua"
local ok, work_config = pcall(function()
  return loadfile(work_config_path)()
end)
if ok then
  -- Set global variables from work config
  for key, value in pairs(work_config) do
    vim.g[key] = value
  end
end

-- leader key
vim.g.mapleader = ' '

require("lazy").setup("plugins")
require "personal.keymaps"
require "personal.options"
require "personal.treesitter"
require "personal.comment"
require "personal.lsp"
require "personal.git"
require "personal.dap"
require "personal.buffer"
require "personal.neotest"

require("personal.dprint").setup()
