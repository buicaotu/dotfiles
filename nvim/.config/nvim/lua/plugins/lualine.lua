
return {
  'nvim-lualine/lualine.nvim',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    'christopher-francisco/tmux-status.nvim',
  },
  config = function()
    local tmux = require('tmux-status')
    tmux.setup({
      colors = {
        window_active = '#d4d4d4',
        window_inactive = '#858585',
        window_inactive_recent = '#858585',
        session = '#007acc',
        datetime = '#858585',
      },
    })

    require('lualine').setup({
      options = {
        theme = 'auto',
        section_separators = '',
        component_separators = '',
        globalstatus = true,
      },
      sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch', 'diff', 'diagnostics'},
        lualine_c = {
          {
            'filename',
            path = 1,
            shorting_target = 40,
          },
        },
        lualine_x = {'encoding', 'fileformat', 'filetype'},
        lualine_y = {'progress'},
        lualine_z = {
          'location',
          { tmux.tmux_session, cond = tmux.show },
          { tmux.tmux_windows, cond = tmux.show },
        }
      },
      tabline = {
        lualine_a = {'buffers'},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {'tabs'}
      },
    })
  end,
}
