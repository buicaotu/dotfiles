-- ~/.config/nvim/lua/plugins/expresso.lua
-- Enabled when java_lsp = "expresso" and work_repo are set in .env.lua.
-- The root is resolved when the first java buffer loads the plugin: the
-- checkout/worktree of work_repo that file (or cwd) is in.

return {
    dir = "~/.local/share/expresso/nvim",
    name = "expresso.nvim",
    enabled = vim.g.java_lsp == "expresso" and vim.g.work_repo ~= nil,
    dependencies = { "neovim/nvim-lspconfig" },
    ft = "java",
    opts = {
      extra_args = { "--bsp-backend=maven" },
    },
    config = function(_, opts)
      local work_root = require("personal.work_root")
      opts.root = work_root(vim.api.nvim_buf_get_name(0)) or work_root(vim.fn.getcwd())
      if not opts.root then
        return -- not in the work repo
      end
      require("expresso").setup(opts)
    end,
}
