local wezterm = require 'wezterm'


return {
  window_background_opacity = 0.75,

  -- Note that nushell config overwrites these settings
  colors = {
    foreground = '#e0def4',
    background = '#232136',
    cursor_bg = '#e0def4',
    cursor_fg = '#232136',
    ansi = {
      '#393552',
      '#eb6f92', 
      '#3e8fb0',
      '#f6c177',
      '#9ccfd8',
      '#c4a7e7',
      '#3e8fb0',
      '#e0def4',
    },
    brights = {
      '#6e6a86',
      '#eb6f92',
      '#3e8fb0', 
      '#f6c177',
      '#9ccfd8',
      '#c4a7e7',
      '#3e8fb0',
      '#e0def4',
    },
  },
  font_size = 12.0,

  default_prog = {'nu.exe'},
  
  leader = { key = "q", mods = "CTRL", timeout_milliseconds = 1000 },
  keys = {
    -- Split vertically with Ctrl+Shift+S
    { key = 's', mods = 'CTRL|SHIFT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    -- Split horizontally with Ctrl+Shift+Z
    { key = 'z', mods = 'CTRL|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
    { key = 'm', mods = 'CTRL|SHIFT', action = wezterm.action.CloseCurrentPane { confirm = true } },
    -- Resize panes (using Ctrl+Alt to avoid conflict with default navigation)
    { key = 'LeftArrow', mods = 'ALT', action = wezterm.action.AdjustPaneSize { 'Left', 5 } },
    { key = 'RightArrow', mods = 'ALT', action = wezterm.action.AdjustPaneSize { 'Right', 5 } },
    { key = 'UpArrow', mods = 'ALT', action = wezterm.action.AdjustPaneSize { 'Up', 5 } },
    { key = 'DownArrow', mods = 'ALT', action = wezterm.action.AdjustPaneSize { 'Down', 5 } },
  },
}