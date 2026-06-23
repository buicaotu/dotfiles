return {
  'Mofiqul/vscode.nvim',
  opts = {
    transparent = true,
    italic_comments = true,
    disable_nvimtree_bg = true,
    -- Diff tones; also consumed by personal.git.diff_highlight for the
    -- directional (old=red / new=green) per-window coloring.
    color_overrides = {
      vscDiffGreenDark = "#006222",
      vscDiffGreenLight = "#033014",
    },
  },
  init = function()
    vim.o.background = 'dark'
    vim.cmd.colorscheme "vscode"
  end
}
