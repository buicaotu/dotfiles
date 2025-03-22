return {
  "stevearc/oil.nvim",
  opts = {
    keymaps = {
      ['<leader>y'] = 'actions.copy_entry_path',
      ['<leader>c'] = 'actions.cd',
      ['<leader>r'] = ':OilGrep<CR>',
      ['<leader>s'] = ':OilFiles<CR>',
      ['<leader>v'] = 'actions.select_vsplit',
      ['<leader>i'] = 'actions.preview',
      ['<Tab>'] = 'actions.select',
      -- remove original keymapping
      ['<C-p>'] = false, -- preview
      ['<C-h>'] = false, -- split
    }
  },
  init = function()
    -- Define custom commands
    vim.api.nvim_create_user_command("OilGrep", function(opts)
      local oil = require("oil");
      local dir = oil.get_current_dir() or vim.fn.expand("%:p:h")
      if vim.bo.filetype == "oil" then
        oil.close()
      end
      require("fzf-lua").grep({
        cwd = dir,
        input_prompt = 'Grep in ' .. dir .. ' ❯ ',
        search = opts.fargs[1],
      })
    end, { nargs = "?" })

    -- open fzf files of the current directory
    vim.api.nvim_create_user_command("OilFiles", function()
      local oil = require("oil");
      local dir = oil.get_current_dir() or vim.fn.expand("%:p:h")
      if vim.bo.filetype == "oil" then
        oil.close()
      end
      require("fzf-lua").files({
        cwd = dir,
      })
    end, {})


    local opts = { noremap = true, silent = true, nowait = true }
    -- Open file explorer
    vim.keymap.set("n", "<C-n>", function()
      require("oil").toggle_float()
    end, opts)
    -- OilFiles keymap
    vim.keymap.set("n", "<leader>of", ":OilFiles<CR>", opts)

    -- Redefine 'Browse' as oil.nvim disable netrw
    vim.api.nvim_create_user_command(
      'Browse',
      function (o)
        vim.fn.system { 'open', o.fargs[1] }
      end,
      { nargs = 1 }
    )

    -- replacing gx functionality of netrw
    local openUrl = function()
      return function()
        local file = vim.fn.expand("<cWORD>")
        -- open(macos) || xdg-open(linux)
        if
          string.match(file, "https") == "https"
          or string.match(file, "http") == "http"
        then
          vim.fn.system { 'open', file }
        else
          return print('"' .. file .. '" is not a URL 🙅')
        end
      end
    end
    local open = openUrl()
    vim.keymap.set("n", "gx", open, { desc = "Open url under current word" })
  end
}
