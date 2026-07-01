local M = {}

-- GitHub/VSCode-style directional diff coloring for native vim diff mode.
--
-- Native vim diff applies DiffAdd/DiffChange/DiffText symmetrically to both
-- windows, so a changed line looks identical (red) on both sides. Here we
-- remap those groups per-window via `winhighlight`: the old window becomes
-- all-red, the new window all-green. Filler stays neutral.
--
-- Each diff window's side (old/new) is resolved, in priority order:
--   1. an explicit manual designation (w:diff_side = 'old' | 'new' | 'off'),
--      set by :Diffthisold/:Diffthisnew/:DiffHl* below;
--   2. fugitive: the `fugitive://` buffer is always the OLD revision (this is
--      how :Gdiffsplit/:Gvdiffsplit open the prior version), so its window is
--      old and every other diff window is new;
--   3. fallback: in a clean 2-way split the leftmost window is old.
-- If none of these decide a window (e.g. a 3-way mergetool with no fugitive
-- buffer), it is left at the colorscheme default.

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

local WINHL_FOR = { old = OLD_WINHL, new = NEW_WINHL }

local function manual_side(win)
  local ok, side = pcall(vim.api.nvim_win_get_var, win, 'diff_side')
  if ok and (side == 'old' or side == 'new' or side == 'off') then
    return side
  end
  return nil
end

local function is_fugitive_win(win)
  local name = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
  return name:match('^fugitive://') ~= nil
end

-- Resolve each diff window to 'old' / 'new' / 'off' / nil. 'off' and nil are
-- both left uncolored; 'off' additionally means "decided" so it is never
-- inferred to the opposite side.
local function resolve_sides(diff_wins)
  local sides = {}
  local has_old, has_new = false, false

  for _, dw in ipairs(diff_wins) do
    local side = manual_side(dw.win)
    if not side and is_fugitive_win(dw.win) then
      side = 'old'
    end
    sides[dw.win] = side
    if side == 'old' then
      has_old = true
    elseif side == 'new' then
      has_new = true
    end
  end

  -- An 'old' anchor (fugitive or manual) makes the rest new, and vice versa.
  -- 'old' wins ties so a fugitive revision always reads as red.
  local fill = has_old and 'new' or has_new and 'old' or nil
  if fill then
    for _, dw in ipairs(diff_wins) do
      if not sides[dw.win] then
        sides[dw.win] = fill
      end
    end
    return sides
  end

  -- No anchor: fall back to column position, but only for a clean 2-way split.
  if #diff_wins == 2 and not sides[diff_wins[1].win] and not sides[diff_wins[2].win] then
    local sorted = { diff_wins[1], diff_wins[2] }
    table.sort(sorted, function(a, b) return a.col < b.col end)
    sides[sorted[1].win] = 'old'
    sides[sorted[2].win] = 'new'
  end
  return sides
end

local function apply()
  local tabwins = vim.api.nvim_tabpage_list_wins(0)

  local diff_wins = {}
  for _, win in ipairs(tabwins) do
    if vim.wo[win].diff then
      local pos = vim.api.nvim_win_get_position(win) -- { row, col }
      table.insert(diff_wins, { win = win, col = pos[2] })
    end
  end

  local sides = resolve_sides(diff_wins)
  for _, dw in ipairs(diff_wins) do
    vim.wo[dw.win].winhighlight = WINHL_FOR[sides[dw.win]] or ''
  end

  -- Strip our mappings AND the pinned side from windows that have left diff
  -- mode, so a window reused for a later diff auto-detects from scratch rather
  -- than carrying a stale 'old'/'new'/'off' designation.
  for _, win in ipairs(tabwins) do
    if not vim.wo[win].diff then
      pcall(vim.api.nvim_win_del_var, win, 'diff_side')
      local cur = vim.wo[win].winhighlight
      if cur == OLD_WINHL or cur == NEW_WINHL then
        vim.wo[win].winhighlight = ''
      end
    end
  end
end

-- Hard reset: wipe our per-window state (winhighlight + pinned side) across
-- every window in every tab, rebuild the highlight groups, then re-apply for
-- whatever is still in diff mode. Use when colors get stuck and DiffHlClear /
-- reopening the diff doesn't recover.
function M.reset()
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      pcall(vim.api.nvim_win_del_var, win, 'diff_side')
      local cur = vim.wo[win].winhighlight
      if cur == OLD_WINHL or cur == NEW_WINHL then
        vim.wo[win].winhighlight = ''
      end
    end
  end
  define_highlights()
  apply()
end

-- Pin the current window's side. The designation persists (survives
-- DiffUpdated) until changed or the window leaves diff mode.
local function designate(side)
  vim.api.nvim_win_set_var(0, 'diff_side', side)
  apply()
end

function M.set_old() designate('old') end

function M.set_new() designate('new') end

-- 'off' pins the window to no coloring (so auto-detection won't re-color it).
function M.clear() designate('off') end

-- :diffthis on the current window, pinned to a side. For manual two-file
-- diffs where neither buffer is a fugitive revision.
function M.diffthis_old()
  vim.cmd('diffthis')
  designate('old')
end

function M.diffthis_new()
  vim.cmd('diffthis')
  designate('new')
end

function M.setup()
  local group = vim.api.nvim_create_augroup('PersonalDiffHighlight', { clear = true })

  define_highlights()

  vim.api.nvim_create_user_command('DiffHlOld', M.set_old,
    { desc = 'Pin current window to old-file (red) diff highlight' })
  vim.api.nvim_create_user_command('DiffHlNew', M.set_new,
    { desc = 'Pin current window to new-file (green) diff highlight' })
  vim.api.nvim_create_user_command('DiffHlClear', M.clear,
    { desc = 'Pin current window to no diff highlight' })
  vim.api.nvim_create_user_command('DiffHlReset', M.reset,
    { desc = 'Wipe all diff-highlight state across every window and re-apply' })
  vim.api.nvim_create_user_command('Diffthisold', M.diffthis_old,
    { desc = 'diffthis on current window, pinned as old (red)' })
  vim.api.nvim_create_user_command('Diffthisnew', M.diffthis_new,
    { desc = 'diffthis on current window, pinned as new (green)' })

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
