local opts = { noremap = true, silent = true, nowait = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

-- leader key
vim.g.mapleader = ' '

-- Replace without yank
keymap("v", "p", '"_dP', opts)

-- clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', opts)

-- window
vim.keymap.set('n', '<Tab>', '<C-^>', opts)

-- Terminal
-- Paste from registers in terminal mode: <C-r> then register name (e.g., <C-r>+ for clipboard)
vim.keymap.set('t', '<c-r>', function()
  local next_char_code = vim.fn.getchar()
  local next_char = vim.fn.nr2char(next_char_code)
  return '<C-\\><C-N>"' .. next_char .. 'pi'
end, { expr = true })
-- Terminal mode insert exit
vim.keymap.set('t', '<C-]>', '<C-\\><C-N>', opts)
-- ALT-R sends CTRL-R to the terminal (triggers fzf)
vim.keymap.set('t', '<M-r>', '<C-r>', opts)

-- Close current window, do nothing if it's the last window
vim.api.nvim_set_keymap('n', '<leader>q', ':lua if #vim.api.nvim_list_wins() > 1 then vim.cmd("q") end<CR>',
  { noremap = true, silent = true })

-- buffer
vim.keymap.set('n', '<leader>x', ':bn|bd#<CR>', opts)
vim.keymap.set('n', '<leader>X', ':bn|bd#!<CR>', opts)

vim.keymap.set('n', '<leader>h', function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, opts)

-- Copilot
-- Unmapping the default keybindings (Tab) for Copilot to avoid conflicts
vim.keymap.set('i', '<C-J>', 'copilot#Accept("\\<CR>")', {
  expr = true,
  replace_keycodes = false
})
vim.g.copilot_no_tab_map = true

vim.keymap.set({ "n", "v" }, "<leader>aa", function()
  require("avante.api").ask()
end, opts)
vim.keymap.set({ "v" }, "<leader>ar", function()
  require("avante.api").refresh()
end, opts)
vim.keymap.set({ "n", "v" }, "<leader>ae", function()
  require("avante.api").edit()
end, opts)

-- The keymaps below are special characters sent to neovim from wezterm
-- refer to .wezterm.lua for the keybindings
vim.keymap.set('n', '<Char-0xAA>', '<cmd>write<cr>', opts)
vim.keymap.set('v', '<Char-0xAB>', 'y<cmd>let @+=@0<CR>', opts)
vim.keymap.set({ 'n', 'i' }, '<Char-0xAD>', ':norm "+p', opts)

-- Option+Arrow key mappings in normal mode/insert/terminal mode
vim.keymap.set('n', '<Char-0xB0>', 'b', opts)
vim.keymap.set('i', '<Char-0xB0>', '<C-o>b', opts)
vim.keymap.set('t', '<Char-0xB0>', '<Esc>b', opts)
vim.keymap.set('n', '<Char-0xB1>', 'w', opts)
vim.keymap.set('i', '<Char-0xB1>', '<C-o>w', opts)
vim.keymap.set('t', '<Char-0xB1>', '<Esc>f', opts)

-- common commands mispelled
vim.api.nvim_create_user_command('Wa', function(opts)
  vim.cmd('wa' .. (opts.args ~= '' and ' ' .. opts.args or ''))
end, { nargs = '*' })
vim.api.nvim_create_user_command('Qa', function(opts)
  vim.cmd('qa' .. (opts.args ~= '' and ' ' .. opts.args or ''))
end, { nargs = '*' })

-- Toggle quickfix list and move cursor to it if opened
vim.keymap.set('n', '<leader>Q', function()
  local qf_exists = false
  for _, win in pairs(vim.fn.getwininfo()) do
    if win.quickfix == 1 then
      qf_exists = true
      break
    end
  end
  if qf_exists == true then
    vim.cmd('cclose')
  else
    vim.cmd('copen')
  end
end, opts)
