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
      -- vscDiffRedDark = "#3c1e24",
      -- vscDiffRedLight = "#AD0116",
      -- vscDiffRedLight = "#960116",
      vscDiffRedLight = "#8C0116",
      vscDiffGreenDark = "#006222",
      vscDiffGreenLight = "#033014",
    },
    -- -- Override highlight groups (see ./lua/vscode/theme.lua)
    -- group_overrides = {
    --     -- this supports the same val table as vim.api.nvim_set_hl
    --     -- use colors from this colorscheme by requiring vscode.colors!
    --     Cursor = { fg=c.vscDarkBlue, bg=c.vscLightGreen, bold=true },
    -- }
  },
  init = function()
    vim.o.background = 'dark'
    vim.cmd.colorscheme "vscode"
  end
}
