local M = {}

-- GitHub/VSCode-style directional diff coloring for native vim diff mode.
--
-- Native vim diff applies DiffAdd/DiffChange/DiffText symmetrically to both
-- windows, so a changed line looks identical (red) on both sides. Here we
-- remap those groups per-window via `winhighlight`: the left (old) window
-- becomes all-red, the right (new) window all-green. Filler stays neutral.
--
-- This relies on the fugitive workflow opening the OLD revision on the LEFT
-- and the current/NEW revision on the RIGHT (Gvdiffsplit!). Directional
-- coloring is only applied to a clean 2-way split; anything else (e.g. a
-- 3-way mergetool) falls back to the colorscheme defaults.

-- The red/green tones are pulled from the vscode theme (incl. the
-- color_overrides set in lua/plugins/vscode.lua) so directional diffs match
-- the rest of the colorscheme. Line-level shades are subtle; *_text shades
-- mark the precise changed characters and are brighter. Filler is a neutral
-- grey since it represents absent content, not an old/new tone.
local function build_palette()
  local ok, colors = pcall(function() return require('vscode.colors').get_colors() end)
  if not ok then
    -- Fallback if the vscode theme isn't available.
    return {
      old_line = '#4B1818', old_text = '#6F1313',
      new_line = '#033014', new_text = '#006222',
      filler   = '#2A2A2A',
    }
  end
  return {
    old_line = colors.vscDiffRedDark,    -- removed/old line background (red, subtle)
    old_text = colors.vscDiffRedLight,   -- changed chars on the old side (brighter red)
    new_line = colors.vscDiffGreenLight, -- added/new line background (green, subtle)
    new_text = colors.vscDiffGreenDark,  -- changed chars on the new side (brighter green)
    filler   = '#2A2A2A',                -- neutral grey for filler placeholder lines
  }
end

local function define_highlights()
  local palette = build_palette()
  local set = vim.api.nvim_set_hl
  set(0, 'DiffAddOld',    { bg = palette.old_line, fg = 'NONE' })
  set(0, 'DiffChangeOld', { bg = palette.old_line, fg = 'NONE' })
  set(0, 'DiffTextOld',   { bg = palette.old_text, fg = 'NONE' })
  set(0, 'DiffAddNew',    { bg = palette.new_line, fg = 'NONE' })
  set(0, 'DiffChangeNew', { bg = palette.new_line, fg = 'NONE' })
  set(0, 'DiffTextNew',   { bg = palette.new_text, fg = 'NONE' })
  -- Override the colorscheme's red DiffDelete so filler is direction-neutral.
  set(0, 'DiffDelete',    { bg = palette.filler, fg = palette.filler })
end

local OLD_WINHL = 'DiffAdd:DiffAddOld,DiffChange:DiffChangeOld,DiffText:DiffTextOld'
local NEW_WINHL = 'DiffAdd:DiffAddNew,DiffChange:DiffChangeNew,DiffText:DiffTextNew'

local function apply()
  local tabwins = vim.api.nvim_tabpage_list_wins(0)

  -- Collect diff windows with their screen column (leftmost = old).
  local diff_wins = {}
  for _, win in ipairs(tabwins) do
    if vim.wo[win].diff then
      local pos = vim.api.nvim_win_get_position(win) -- { row, col }
      table.insert(diff_wins, { win = win, col = pos[2] })
    end
  end

  -- Only a clean 2-way split gets directional coloring.
  local directional = #diff_wins == 2
  if directional then
    table.sort(diff_wins, function(a, b) return a.col < b.col end)
  end

  for i, dw in ipairs(diff_wins) do
    local target = ''
    if directional then
      target = (i == 1) and OLD_WINHL or NEW_WINHL
    end
    vim.wo[dw.win].winhighlight = target
  end

  -- Strip our mappings from windows that have left diff mode.
  for _, win in ipairs(tabwins) do
    if not vim.wo[win].diff then
      local cur = vim.wo[win].winhighlight
      if cur == OLD_WINHL or cur == NEW_WINHL then
        vim.wo[win].winhighlight = ''
      end
    end
  end
end

-- Manually force the current window's diff coloring (overrides the automatic
-- position-based assignment until the next DiffUpdated). Useful when the
-- old/new sides are reversed, or in layouts the auto logic skips (e.g. a
-- 3-way mergetool).
function M.set_old()
  vim.wo.winhighlight = OLD_WINHL
end

function M.set_new()
  vim.wo.winhighlight = NEW_WINHL
end

function M.clear()
  vim.wo.winhighlight = ''
end

function M.setup()
  local group = vim.api.nvim_create_augroup('PersonalDiffHighlight', { clear = true })

  define_highlights()

  vim.api.nvim_create_user_command('DiffHlOld', M.set_old,
    { desc = 'Apply old-file (red) diff highlight to current window' })
  vim.api.nvim_create_user_command('DiffHlNew', M.set_new,
    { desc = 'Apply new-file (green) diff highlight to current window' })
  vim.api.nvim_create_user_command('DiffHlClear', M.clear,
    { desc = 'Clear custom diff highlight on current window' })

  -- Re-define our groups whenever the colorscheme reloads.
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = group,
    callback = define_highlights,
  })

  -- Re-assign per-window mappings whenever vim recomputes diffs.
  vim.api.nvim_create_autocmd('DiffUpdated', {
    group = group,
    callback = apply,
  })
end

return M
