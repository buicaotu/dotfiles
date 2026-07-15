return {
  "tpope/vim-surround",
  -- Disable all default mappings (must be set before the plugin loads). 
  init = function()
    vim.g.surround_no_mappings = 1
  end,
  -- Lazy-load on the keys we actually use. vim-surround defines its `<Plug>`
  -- maps unconditionally, so binding to them (remap = true) works once loaded.
  keys = {
    { "cs", "<Plug>Csurround", mode = "n", remap = true, desc = "Change surround" },
    { "ds", "<Plug>Dsurround", mode = "n", remap = true, desc = "Delete surround" },
    { "S", "<Plug>VSurround", mode = "x", remap = true, desc = "Surround selection" },
  },
}
