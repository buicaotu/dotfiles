local wezterm = require('wezterm')

local function is_vim(pane)
  local is_vim_env = pane:get_user_vars().IS_NVIM == 'true'
  if is_vim_env == true then return true end
  -- This gsub is equivalent to POSIX basename(3)
  -- Given "/foo/bar" returns "bar"
  -- Given "c:\\foo\\bar" returns "bar"
  local process_name = string.gsub(pane:get_foreground_process_name(), '(.*[/\\])(.*)', '%2')
  return process_name == 'nvim' or process_name == 'vim'
end

--- Keys that we want to send to neovim based on modifier combinations
local vim_keys_map = {
  -- CMD+key mappings
  ['CMD'] = {
    s = ':w\r',
    c = utf8.char(0xAB),
  },
  -- ALT+key mappings
  ['ALT'] = {
    LeftArrow = utf8.char(0xB0),
    RightArrow = utf8.char(0xB1),
  },
}

local function bind_key_to_vim(mods, key)
  return {
    key = key,
    mods = mods,
    action = wezterm.action_callback(function(win, pane)
      local char = vim_keys_map[mods] and vim_keys_map[mods][key]
      if char and is_vim(pane) then
        -- pass the keys through to vim/nvim
        win:perform_action({
          SendKey = { key = char, mods = nil },
        }, pane)
      else
        win:perform_action({
          SendKey = {
            key = key,
            mods = mods
          }
        }, pane)
      end
    end)
  }
end

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config.keys = {
  -- Vim passthrough
  bind_key_to_vim('CMD', 's'),
  bind_key_to_vim('CMD', 'c'),
  bind_key_to_vim('ALT', 'LeftArrow'),
  bind_key_to_vim('ALT', 'RightArrow'),

  -- Pane splits
  {
    key = '\\',
    mods = 'CTRL',
    action = wezterm.action.SplitPane({ direction = 'Right' }),
  },
  {
    key = '|',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SplitPane({ direction = 'Down' }),
  },

  -- Pane navigation
  {
    key = 'n',
    mods = 'CMD|SHIFT',
    action = wezterm.action.ActivatePaneDirection('Next'),
  },
  {
    key = 'h',
    mods = 'CMD|SHIFT',
    action = wezterm.action.ActivatePaneDirection('Left'),
  },
  {
    key = 'l',
    mods = 'CMD|SHIFT',
    action = wezterm.action.ActivatePaneDirection('Right'),
  },
  {
    key = 'k',
    mods = 'CMD|SHIFT',
    action = wezterm.action.ActivatePaneDirection('Up'),
  },
  {
    key = 'j',
    mods = 'CMD|SHIFT',
    action = wezterm.action.ActivatePaneDirection('Down'),
  },

  -- Pane resize
  {
    key = 'LeftArrow',
    mods = 'CMD',
    action = wezterm.action.AdjustPaneSize({ 'Left', 5 }),
  },
  {
    key = 'RightArrow',
    mods = 'CMD',
    action = wezterm.action.AdjustPaneSize({ 'Right', 5 }),
  },
  {
    key = 'UpArrow',
    mods = 'CMD',
    action = wezterm.action.AdjustPaneSize({ 'Up', 5 }),
  },
  {
    key = 'DownArrow',
    mods = 'CMD',
    action = wezterm.action.AdjustPaneSize({ 'Down', 5 }),
  },
  {
    key = 'm',
    mods = 'CMD|SHIFT',
    action = wezterm.action.TogglePaneZoomState,
  },

  -- Scrolling
  {
    key = 'u',
    mods = 'CMD',
    action = wezterm.action.ScrollByLine(-3),
  },
  {
    key = 'd',
    mods = 'CMD',
    action = wezterm.action.ScrollByLine(3),
  },

  -- Quick select
  {
    key = 'f',
    mods = 'CMD|SHIFT',
    action = wezterm.action.QuickSelect,
  },
}
config.window_background_opacity = 0.85
config.inactive_pane_hsb = {
  saturation = 0.8,
  brightness = 0.6,
}
config.font_size = 20.0
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 500

return config
