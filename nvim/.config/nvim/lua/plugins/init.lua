return {
  -- LSP Support
  { 'neovim/nvim-lspconfig' },
  { 'williamboman/mason.nvim' },
  { 'williamboman/mason-lspconfig.nvim' },

  -- Autocompletion
  { "lukas-reineke/lsp-format.nvim" },
  { "github/copilot.vim" },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ':TSUpdate',
    init = function()
      -- Queries moved to runtime/queries/ in the main branch rewrite,
      -- but lazy.nvim only adds plugin.dir (not plugin.dir/runtime) to rtp.
      vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/runtime")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
  },

  -- Debug
  { "mfussenegger/nvim-dap" },
  {
    "rcarriga/nvim-dap-ui", 
    dependencies = { "nvim-neotest/nvim-nio" }
  },

  -- Formatting
  {
    url = "org-2562356@github.com:Canva/dprint-vim-plugin.git",
    event = "BufWritePre",
    lazy = true,
    enabled = vim.g.enable_dprint or false,
  },

  -- Testing
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-jest",
    }
  },

  -- Git
  { "tpope/vim-fugitive" },
  { "tpope/vim-rhubarb" },
  { "tpope/vim-dispatch" },

  -- UI
  { 'j-hui/fidget.nvim',     opts = {} },
  { 'echasnovski/mini.move', version = false, opts = {} },

  -- Editing
  { "tpope/vim-surround" },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true

  },
  {
    "windwp/nvim-ts-autotag",
    config = true
  },

  -- Misc
  { 'nvim-lua/plenary.nvim' },
  { 'christoomey/vim-tmux-navigator' },
  { 'JoosepAlviste/nvim-ts-context-commentstring', opts = { enable_autocmd = false } },
  { 'lukas-reineke/indent-blankline.nvim' },
  {
    'chrishrb/gx.nvim',
    keys = {
      { "gx", "<cmd>Browse<cr>", mode = { "n", "x" } }
    },
    cmd = { "Browse" },
    init = function()
      vim.g.netrw_nogx = 1
    end,
    opts = {
      handlers = {
        search = false,
      },
    },
  },

  -- Rust
  {
    'mrcjkb/rustaceanvim',
    version = '^6', -- Recommended
    lazy = false,   -- This plugin is already lazy
  },
}
