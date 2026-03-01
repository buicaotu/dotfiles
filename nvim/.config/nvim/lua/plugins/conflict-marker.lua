return {
  'tronikelis/conflict-marker.nvim',
  lazy = false,
  opts = {
    on_attach = function(conflict)
      local map = function(key, fn, desc)
        vim.keymap.set("n", key, fn, { buffer = conflict.bufnr, desc = desc })
      end

      map("co", function() conflict:choose_ours() end, "Conflict: choose ours")
      map("ct", function() conflict:choose_theirs() end, "Conflict: choose theirs")
      map("cb", function() conflict:choose_both() end, "Conflict: choose both")
      map("cn", function() conflict:choose_none() end, "Conflict: choose none")

      local START = "^<<<<<<<"

      map("]x", function() vim.cmd("/" .. START) end, "Next conflict")
      map("[x", function() vim.cmd("?" .. START) end, "Prev conflict")
    end,
  },
}
