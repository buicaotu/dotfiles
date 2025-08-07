vim.opt.cursorline     = true  -- highlight the current line
vim.opt.signcolumn     = "yes" -- always show signcolumn
vim.opt.scrolloff      = 8
vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.incsearch      = true -- highlight search term incrementally
vim.opt.grepprg        = "rg --vimgrep --follow"
vim.opt.grepformat     = "%f:%l:%c:%m"
vim.opt.laststatus     = 3

-- Search settings
vim.opt.ignorecase     = true -- Search ignore case by default
vim.opt.smartcase      = true -- Use case sensitive when there is capital letter

-- Indentation settings
vim.opt.tabstop        = 2
vim.opt.softtabstop    = 2
vim.opt.shiftwidth     = 2
vim.opt.expandtab      = true -- expand tabs to spaces

-- UI settings
vim.opt.mouse          = "a" -- Use mouse
vim.opt.list           = true
vim.opt.listchars      = {
  tab = "> ",
  trail = "~",
  nbsp = "+",
  eol = "$"
}

-- Performance settings
vim.opt.updatetime     = 500 -- Default 4000, time for plugin to update

-- Git conflict highlighting
vim.cmd([[
  highlight ConflictMarkerBegin ctermbg=34
  highlight ConflictMarkerOurs ctermbg=22
  highlight ConflictMarkerTheirs ctermbg=27
  highlight ConflictMarkerEnd ctermbg=39
  highlight ConflictMarkerCommonAncestorsHunk ctermbg=yellow
]])
