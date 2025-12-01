local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
  return
end

configs.setup({
  ensure_installed = { "bash", "c", "javascript", "json", "lua", "python", "typescript", "tsx", "css", "rust", "java", "yaml", "markdown", "markdown_inline", "kotlin" }, -- one of "all" or a list of languages
  sync_install = false,
  auto_install = true,
  ignore_install = { "phpdoc" }, -- List of parsers to ignore installing
  highlight = {
    enable = true,               -- false will disable the whole extension
    disable = { "vim" },         -- list of language that will be disabled
  },
  autopairs = {
    enable = true,
  },
  indent = { enable = true, disable = { "python", "css" } },
  textobjects = {
    select = {
      enable = true,

      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,

      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ai"] = "@conditional.outer",
        ["ii"] = "@conditional.inner",
        ["ac"] = "@class.outer",
        ["ab"] = "@brackets.outer",
        ["ib"] = "@brackets.inner",
        ["al"] = "@loop.outer",
        ["il"] = "@loop.inner",
        -- ["ap"] = "@parameter.outer",
        -- ["ip"] = "@parameter.inner",
        -- You can optionally set descriptions to the mappings (used in the desc parameter of
        -- nvim_buf_set_keymap) which plugins like which-key display
        ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
        -- You can also use captures from other query groups like `locals.scm`
        -- ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
        ["ax"] = "@comment.outer",
        -- Define 'iq' as inner quote and 'aq' as a quote
        ["i'"] = {
          query = "@quote.inner",
          desc = "Select inner content of quotes (single, double, backtick)"
        },
        ["a'"] = {
          query = "@quote.outer",
          desc = "Select entire quoted string (single, double, backtick)"
        },
        ["aa"] = {
          query = "@jsxa",
          desc = "Select JSX attribute",
        },
        ["``"] = {
          query = "@code_block",
          des   = "Markdown code block",
        }
      },
      -- You can choose the select mode (default is charwise 'v')
      --
      -- Can also be a function which gets passed a table with the keys
      -- * query_string: eg '@function.inner'
      -- * method: eg 'v' or 'o'
      -- and should return the mode ('v', 'V', or '<c-v>') or a table
      -- mapping query_strings to modes.
      selection_modes = {
        ['@parameter.outer'] = 'v', -- charwise
        ['@function.outer'] = 'V',  -- linewise
        ['@class.outer'] = '<c-v>', -- blockwise
      },
      -- If you set this to `true` (default is `false`) then any textobject is
      -- extended to include preceding or succeeding whitespace. Succeeding
      -- whitespace has priority in order to act similarly to eg the built-in
      -- `ap`.
      --
      -- Can also be a function which gets passed a table with the keys
      -- * query_string: eg '@function.inner'
      -- * selection_mode: eg 'v'
      -- and should return true of false
      include_surrounding_whitespace = false,
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        ["]f"] = "@function.outer",
        -- ["]c"] = { query = "@class.outer", desc = "Next class start" },
        ["]b"] = "@brackets.outer",
        --
        -- You can use regex matching (i.e. lua pattern) and/or pass a list in a "query" key to group multiple queires.
        -- ["]o"] = "@loop.*",
        -- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
        --
        -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
        -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
        -- ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
        ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
        ["]'"] = { query = "@quote.outer", desc = "Next quote" },
        ["]x"] = { query = "@comment.outer", desc = "Next comment" },
        ["]a"] = "@jsxa",
      },
      goto_next_end = {
        ["]F"] = "@function.outer",
        ["]B"] = "@brackets.outer",
        -- ["]c"] = "@class.outer",
        ["]A"] = "@jsxa",
      },
      goto_previous_start = {
        ["[f"] = "@function.outer",
        ["[b"] = "@brackets.outer",
        ["[["] = "@class.outer",
        ["['"] = { query = "@quote.outer", desc = "Previous quote" },
        ["[x"] = { query = "@comment.outer", desc = "Previous comment" },
        ["[a"] = "@jsxa",
      },
      goto_previous_end = {
        ["[F"] = "@function.outer",
        ["[B"] = "@brackets.outer",
        ["[c"] = "@class.outer",
        ["[A"] = "@jsxa",
      },
      -- Below will go to either the start or the end, whichever is closer.
      -- Use if you want more granular movements
      -- Make it even more gradual by adding multiple queries and regex.
      goto_next = {
        ["]i"] = "@conditional.outer",
      },
      goto_previous = {
        ["[i"] = "@conditional.outer",
      }
    },
    -- swap = {
    --   enable = true,
    --   swap_next = {
    --     ["<leader>a"] = "@parameter.inner",
    --   },
    --   swap_previous = {
    --     ["<leader>q"] = "@parameter.inner",
    --   },
    -- },
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      node_incremental = "=",
      node_decremental = "-",
    },
  },
  modules = {},
})

local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")
local wk = require("which-key")

-- Helpers to wrap simple commands in the new repeatable move signature
local bmove = ts_repeat_move.make_repeatable_move(function(opts)
  if opts.forward then
    vim.cmd("bnext")
  else
    vim.cmd("bprevious")
  end
end)

local cqmove = ts_repeat_move.make_repeatable_move(function(opts)
  if opts.forward then
    vim.cmd("Cnext")
  else
    vim.cmd("Cprev")
  end
end)

local cqstack = ts_repeat_move.make_repeatable_move(function(opts)
  if opts.forward then
    vim.cmd("cnewer")
  else
    vim.cmd("colder")
  end
end)

wk.add({
  -- Repeat movement with ; and ,
  { ";",  ts_repeat_move.repeat_last_move,          desc = "Repeat last move",            mode = { "n", "x", "o" } },
  { ",",  ts_repeat_move.repeat_last_move_opposite, desc = "Repeat last move (opposite)", mode = { "n", "x", "o" } },

  -- Make builtin f, F, t, T also repeatable with ; and ,
  { "f",  ts_repeat_move.builtin_f_expr,            desc = "Find char forward",           mode = { "n", "x", "o" }, expr = true },
  { "F",  ts_repeat_move.builtin_F_expr,            desc = "Find char backward",          mode = { "n", "x", "o" }, expr = true },
  { "t",  ts_repeat_move.builtin_t_expr,            desc = "Till char forward",           mode = { "n", "x", "o" }, expr = true },
  { "T",  ts_repeat_move.builtin_T_expr,            desc = "Till char backward",          mode = { "n", "x", "o" }, expr = true },

  -- Buffer navigation
  { "]",  group = "Next" },
  { "[",  group = "Previous" },
  { "]t", function() bmove({ forward = true }) end, desc = "Next buffer",                 mode = { "n", "x", "o" } },
  { "[t", function() bmove({ forward = false }) end, desc = "Previous buffer",             mode = { "n", "x", "o" } },

  -- Quickfix navigation
  { "]q", function() cqmove({ forward = true }) end, desc = "Next quickfix item",          mode = { "n", "x", "o" } },
  { "[q", function() cqmove({ forward = false }) end, desc = "Previous quickfix item",      mode = { "n", "x", "o" } },
  { "]Q", function() cqstack({ forward = true }) end, desc = "Newer quickfix list",         mode = { "n", "x", "o" } },
  { "[Q", function() cqstack({ forward = false }) end, desc = "Older quickfix list",         mode = { "n", "x", "o" } },
})

local context_ok, context = pcall(require, "treesitter-context")
if context_ok then
  context.setup {
    enable = true,            -- Enable this plugin (Can be enabled/disabled later via commands)
    max_lines = 3,            -- How many lines the window should span. Values <= 0 mean no limit.
    min_window_height = 0,    -- Minimum editor window height to enable context. Values <= 0 mean no limit.
    line_numbers = true,
    multiline_threshold = 10, -- Maximum number of lines to show for a single context
    trim_scope = 'outer',     -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
    mode = 'cursor',          -- Line used to calculate context. Choices: 'cursor', 'topline'
    -- Separator between context and content. Should be a single character string, like '-'.
    -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
    separator = '-',
    zindex = 20,     -- The Z-index of the context window
    on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
  }
else
  vim.api.nvim_err_writeln("[Error] " .. "failed to setup treesitter-context")
end
