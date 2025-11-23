return {
  "stevearc/oil.nvim",
  opts = {
    keymaps = {
      ['<leader>y'] = 'actions.copy_entry_path',
      ['<leader>c'] = 'actions.cd',
      ['<leader>v'] = 'actions.select_vsplit',
      ['<leader>i'] = 'actions.preview',
      ['<Tab>'] = 'actions.select',
      -- remove original keymapping
      ['<C-p>'] = false, -- preview
      ['<C-h>'] = false, -- split
    }
  },
  init = function()
    local wk = require("which-key")
    wk.add({
      {
        "<C-n>",
        function()
          require("oil").toggle_float()
        end,
        desc = "Toggle Oil file explorer",
        mode = "n",
      },
    })
  end
}
