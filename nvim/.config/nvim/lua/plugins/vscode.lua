return {
  'Mofiqul/vscode.nvim',
  opts = {
    -- Alternatively set style in setup
    -- style = 'light'
    -- Enable transparent background
    transparent = true,
    -- Enable italic comment
    italic_comments = true,
    -- Disable nvim-tree background color
    disable_nvimtree_bg = true,
    -- Override colors (see ./lua/vscode/colors.lua)
    color_overrides = {
      -- vscLineNumber = '#FFFFFF',
      -- original
      -- vscDiffRedDark = '#4B1818',
      -- vscDiffRedLight = '#6F1313',
      -- vscDiffRedLightLight = '#FB0101',
      -- lighter light
      -- vscDiffRedLight = "#8C0116",
      vscDiffRedLightLight = '#911313',
      vscDiffGreenDark = "#006222",
      vscDiffGreenLight = "#033014",
    },
    -- -- Override highlight groups (see ./lua/vscode/theme.lua)
    group_overrides = {
        -- this supports the same val table as vim.api.nvim_set_hl
        -- use colors from this colorscheme by requiring vscode.colors!
        DiffText = { fg='NONE', bg='#911313', },
    }
  },
  init = function()
    vim.o.background = 'dark'
    vim.cmd.colorscheme "vscode"
  end
}
