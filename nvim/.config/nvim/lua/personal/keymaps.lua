local wk = require("which-key")

wk.add({
  -- Visual mode mappings
  { "p",         '"_dP',  desc = "Paste without yank",     mode = "v" },

  -- Clipboard
  { "<leader>y", '"+y',   desc = "Yank to clipboard",      mode = { "n", "v" } },

  -- Window navigation
  { "<Tab>",     "<C-^>", desc = "Toggle between buffers", mode = "n" },

  -- Terminal mappings
  {
    "<c-r>",
    function()
      local next_char_code = vim.fn.getchar()
      local next_char = vim.fn.nr2char(next_char_code)
      return '<C-\\><C-N>"' .. next_char .. 'pi'
    end,
    desc = "Paste from register in terminal",
    mode = "t",
    expr = true,
  },
  { "<C-]>",     "<C-\\><C-N>",  desc = "Exit terminal mode",          mode = "t" },

  -- Window management
  {
    "<leader>q",
    function()
      if #vim.api.nvim_list_wins() > 1 then
        vim.cmd("q")
      end
    end,
    desc = "Close window",
    mode = "n",
  },

  -- Buffer management
  { "<leader>x", ":bn|bd#<CR>",  desc = "Delete buffer (keep window)", mode = "n" },
  { "<leader>X", ":bn|bd#!<CR>", desc = "Delete buffer! (force)",      mode = "n" },

  -- LSP Inlay hints
  {
    "<leader>h",
    function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
    end,
    desc = "Toggle inlay hints",
    mode = "n",
  },

  -- Copilot
  { "<C-J>",     'copilot#Accept("\\<CR>")', desc = "Accept Copilot suggestion", mode = "i", expr = true, replace_keycodes = false },

  -- Avante
  { "<leader>a", group = "Avante" },
  {
    "<leader>aa",
    function()
      require("avante.api").ask()
    end,
    desc = "Ask Avante",
    mode = { "n", "v" },
  },
  {
    "<leader>ar",
    function()
      require("avante.api").refresh()
    end,
    desc = "Refresh Avante",
    mode = "v",
  },
  {
    "<leader>ae",
    function()
      require("avante.api").edit()
    end,
    desc = "Edit with Avante",
    mode = { "n", "v" },
  },

  -- Special characters from wezterm
  { "<Char-0xAA>", "<cmd>write<cr>",      desc = "Save file",            mode = "n" },
  { "<Char-0xAB>", 'y<cmd>let @+=@0<CR>', desc = "Copy to clipboard",    mode = "v" },
  { "<Char-0xAD>", ':norm "+p',           desc = "Paste from clipboard", mode = { "n", "i" } },

  -- Option+Arrow key mappings
  { "<Char-0xB0>", "b",                   desc = "Move word backward",   mode = "n" },
  { "<Char-0xB0>", "<C-o>b",              desc = "Move word backward",   mode = "i" },
  { "<Char-0xB0>", "<Esc>b",              desc = "Move word backward",   mode = "t" },
  { "<Char-0xB1>", "w",                   desc = "Move word forward",    mode = "n" },
  { "<Char-0xB1>", "<C-o>w",              desc = "Move word forward",    mode = "i" },
  { "<Char-0xB1>", "<Esc>f",              desc = "Move word forward",    mode = "t" },

  -- Quickfix list
  {
    "<leader>Q",
    function()
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
    end,
    desc = "Toggle quickfix list",
    mode = "n",
  },
})

-- Copilot configuration
vim.g.copilot_no_tab_map = true

-- Common commands misspelled
vim.api.nvim_create_user_command('Wa', function(opts)
  vim.cmd('wa' .. (opts.args ~= '' and ' ' .. opts.args or ''))
end, { nargs = '*' })

vim.api.nvim_create_user_command('Qa', function(opts)
  vim.cmd('qa' .. (opts.args ~= '' and ' ' .. opts.args or ''))
end, { nargs = '*' })
