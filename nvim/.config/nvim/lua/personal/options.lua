vim.opt.cursorline     = true  -- highlight the current line
vim.opt.signcolumn     = "yes" -- always show signcolumn
vim.opt.scrolloff      = 8
vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.incsearch      = true -- highlight search term incrementally
vim.opt.grepprg        = "rg --vimgrep --follow"
vim.opt.grepformat     = "%f:%l:%c:%m"
vim.opt.laststatus     = 3
vim.opt.splitright     = true

-- Search settings
vim.opt.ignorecase     = true -- Search ignore case by default
vim.opt.smartcase      = true -- Use case sensitive when there is capital letter

-- Indentation settings
vim.opt.tabstop        = 2
vim.opt.softtabstop    = 2
vim.opt.shiftwidth     = 2
vim.opt.expandtab      = true -- expand tabs to spaces

-- Diff
vim.opt.diffopt:append({
  "algorithm:patience", -- or "algorithm:histogram"
  "indent-heuristic",
  "linematch:60",
  "context:10"
})

-- UI settings
vim.opt.mouse      = "a" -- Use mouse
vim.opt.list       = true
vim.opt.listchars  = {
  tab = "> ",
  trail = "~",
  nbsp = "+",
  eol = "$"
}

-- Performance settings
vim.opt.updatetime = 500 -- Default 4000, time for plugin to update

-- Fold settings
vim.opt.foldmethod = 'expr'
vim.opt.foldlevel  = 99
vim.opt.foldexpr   = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext   = ""
-- vim.opt.fillchars  = {
--   fold = ' ',
--   foldclose = '', -- ''
--   foldopen = '', -- ''
--   foldsep = ' ',
--   foldinner = ' '
-- }

-- Git conflict highlighting
vim.cmd([[
  highlight ConflictOursMarker ctermbg=34
  highlight ConflictOurs ctermbg=22
  highlight ConflictTheirs ctermbg=27
  highlight ConflictTheirsMarker ctermbg=39
  highlight ConflictBase ctermbg=yellow
]])
