local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
  return
end

configs.setup({
  ensure_installed = { "bash", "c", "javascript", "json", "lua", "python", "typescript", "tsx", "css", "rust", "java", "yaml", "markdown", "markdown_inline", "kotlin" },
  sync_install = false,
  auto_install = true,
  ignore_install = { "phpdoc" },
  highlight = {
    enable = true,
    disable = { "vim" },
  },
  autopairs = {
    enable = true,
  },
  indent = { enable = true, disable = { "python", "css" } },
  incremental_selection = {
    enable = true,
    keymaps = {
      node_incremental = "=",
      node_decremental = "-",
    },
  },
  modules = {},
})

-- nvim-treesitter-textobjects (main branch API)
local ts_ok, ts_textobjects = pcall(require, "nvim-treesitter-textobjects")
if not ts_ok then
  return
end

ts_textobjects.setup({
  select = {
    lookahead = true,
    selection_modes = {
      ['@parameter.outer'] = 'v',
      ['@function.outer'] = 'V',
      ['@class.outer'] = '<c-v>',
    },
    include_surrounding_whitespace = false,
  },
  move = {
    set_jumps = true,
  },
})

local select_textobject = require("nvim-treesitter-textobjects.select").select_textobject
local move = require("nvim-treesitter-textobjects.move")

local select_maps = {
  { "af", "@function.outer" },
  { "if", "@function.inner" },
  { "ai", "@conditional.outer" },
  { "ii", "@conditional.inner" },
  { "ac", "@class.outer" },
  { "ic", "@class.inner" },
  { "ab", "@brackets.outer" },
  { "ib", "@brackets.inner" },
  { "al", "@loop.outer" },
  { "il", "@loop.inner" },
  { "ax", "@comment.outer" },
  { "i'", "@quote.inner" },
  { "a'", "@quote.outer" },
  { "aa", "@jsxa" },
  { "``", "@code_block" },
}

for _, m in ipairs(select_maps) do
  local lhs, query = m[1], m[2]
  vim.keymap.set({ "x", "o" }, lhs, function()
    select_textobject(query)
  end)
end

local move_maps = {
  { "goto_next_start",     "]f", "@function.outer" },
  { "goto_next_start",     "]b", "@brackets.outer" },
  { "goto_next_start",     "]z", "@fold",           "folds" },
  { "goto_next_start",     "]'", "@quote.outer" },
  { "goto_next_start",     "]x", "@comment.outer" },
  { "goto_next_start",     "]a", "@jsxa" },
  { "goto_next_end",       "]F", "@function.outer" },
  { "goto_next_end",       "]B", "@brackets.outer" },
  { "goto_next_end",       "]A", "@jsxa" },
  { "goto_previous_start", "[f", "@function.outer" },
  { "goto_previous_start", "[b", "@brackets.outer" },
  { "goto_previous_start", "[[", "@class.outer" },
  { "goto_previous_start", "['", "@quote.outer" },
  { "goto_previous_start", "[x", "@comment.outer" },
  { "goto_previous_start", "[a", "@jsxa" },
  { "goto_previous_end",   "[F", "@function.outer" },
  { "goto_previous_end",   "[B", "@brackets.outer" },
  { "goto_previous_end",   "[c", "@class.outer" },
  { "goto_previous_end",   "[A", "@jsxa" },
  { "goto_next",           "]i", "@conditional.outer" },
  { "goto_previous",       "[i", "@conditional.outer" },
}

for _, m in ipairs(move_maps) do
  local fn_name, lhs, query, query_group = m[1], m[2], m[3], m[4]
  vim.keymap.set({ "n", "x", "o" }, lhs, function()
    move[fn_name](query, query_group)
  end)
end

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
