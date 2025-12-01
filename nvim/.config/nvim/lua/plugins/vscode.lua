local diff_red_light_light = '#911313'

return {
  'Mofiqul/vscode.nvim',
  opts = {
    transparent = true,
    italic_comments = true,
    disable_nvimtree_bg = true,
    color_overrides = {
      vscDiffRedLightLight = diff_red_light_light,
      vscDiffGreenDark = "#006222",
      vscDiffGreenLight = "#033014",
    },
    group_overrides = {
        DiffText = { fg='NONE', bg=diff_red_light_light, },
    }
  },
  init = function()
    vim.o.background = 'dark'
    vim.cmd.colorscheme "vscode"
  end
}
