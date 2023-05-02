-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'nord'
config.font_size = 13.0;
config.font = wezterm.font { family = "NotoSansMono Nerd Font" };

config.keys = {
  {
    key = 'c',
    mods = 'CTRL',
    action = wezterm.action.CopyTo 'ClipboardAndPrimarySelection',
  },
  {
    key = 'C',
    mods = 'CTRL',
    action = wezterm.action_callback(function(window, pane)
      window:perform_action(wezterm.action.SendKey { key = 'c', mods = 'CTRL' }, pane)
    end),
  },
  {
    key = 'l',
    mods = 'ALT',
    action = wezterm.action.ActivateTabRelative(1),
  },
  {
    key = 'h',
    mods = 'ALT',
    action = wezterm.action.ActivateTabRelative(-1),
  },
  {
    key = 'w',
    mods = 'ALT',
    action = wezterm.action.CloseCurrentPane { confirm = true },
  },
  {
    key = 't',
    mods = 'ALT',
    action = wezterm.action.SpawnTab 'CurrentPaneDomain',
  },
  { key = '-', mods = 'ALT',       action = wezterm.action.DecreaseFontSize },
  -- { key = '+', mods = 'ALT', action = wezterm.action.IncreaseFontSize },
  -- { key = '+', mods = 'ALT', action = wezterm.action.IncreaseFontSize },
  { key = '+', mods = 'ALT|SHIFT', action = wezterm.action.IncreaseFontSize },
  { key = '=', mods = 'ALT',       action = wezterm.action.ResetFontSize },
  -- {
  --   key = 'LeftArrow',
  --   mods = 'ALT',
  --   action = wezterm.action.ActivatePaneDirection 'Left',
  -- },
  -- {
  --   key = 'RightArrow',
  --   mods = 'ALT',
  --   action = wezterm.action.ActivatePaneDirection 'Right',
  -- },
  -- {
  --   key = 'UpArrow',
  --   mods = 'ALT',
  --   action = wezterm.action.ActivatePaneDirection 'Up',
  -- },
  -- {
  --   key = 'DownArrow',
  --   mods = 'ALT',
  --   action = wezterm.action.ActivatePaneDirection 'Down',
  -- },
  {
    key = 'H',
    mods = 'ALT',
    action = wezterm.action.ActivatePaneDirection 'Left',
  },
  {
    key = 'L',
    mods = 'ALT',
    action = wezterm.action.ActivatePaneDirection 'Right',
  },
  {
    key = 'K',
    mods = 'ALT',
    action = wezterm.action.ActivatePaneDirection 'Up',
  },
  {
    key = 'J',
    mods = 'ALT',
    action = wezterm.action.ActivatePaneDirection 'Down',
  },
 {
    key = 'n',
    mods = 'ALT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
 {
    key = 'm',
    mods = 'ALT',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },

 {
    key = 'LeftArrow',
    mods = 'ALT',
    action = wezterm.action.AdjustPaneSize { 'Left', 2 },
  },
  {
    key = 'DownArrow',
    mods = 'ALT',
    action = wezterm.action.AdjustPaneSize { 'Down', 2 },
  },
  {
    key = 'UpArrow',
    mods = 'ALT',
    action = wezterm.action.AdjustPaneSize { 'Up', 2 }
  },
  {
    key = 'LeftArrow',
    mods = 'ALT',
    action = wezterm.action.AdjustPaneSize { 'Right', 2 },
  },
  {
    key = 's',
    mods = 'ALT',
    action = wezterm.action.ShowLauncherArgs { flags = 'WORKSPACES' },
  },
  {
    key = 'd',
    mods = 'ALT',
    action = wezterm.action.ShowLauncherArgs { flags = 'COMMANDS' },
  },
  {
    key = 'f',
    mods = 'ALT',
    action = wezterm.action.PromptInputLine {
      description = wezterm.format {
        { Attribute = { Intensity = 'Bold' } },
        { Foreground = { AnsiColor = 'Fuchsia' } },
        { Text = 'Enter name for new workspace' },
      },
      action = wezterm.action_callback(function(window, pane, line)
        -- line will be `nil` if they hit escape without entering anything
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line then
          window:perform_action(wezterm.action.SwitchToWorkspace { name = line }, pane)
        end
      end),
    },
  },
}

for i = 1, 8 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'ALT',
    action = wezterm.action.ActivateTab(i - 1),
  })
end

config.use_fancy_tab_bar = false
config.check_for_updates = false
-- config.bold_brightens_ansi_colors = false
-- config.freetype_load_target = "Mono"
config.colors = {
  cursor_bg = '#81a1c1',
  -- Overrides the text color when the current cell is occupied by the cursor
  cursor_fg = '#222730',
  tab_bar = {
    background = "#222730",
    active_tab = {
      bg_color = "#2e3440",
      fg_color = "#d8dee9"
    },
    inactive_tab = {
      bg_color = "#222730",
      fg_color = "#667084"
    },
    new_tab = {
      bg_color = "#222730",
      fg_color = "#667084"
    }
  }
}

config.window_padding = {
  left = '0cell',
  right = '0cell',
  top = '0cell',
  bottom = '0cell',
}
-- and finally, return the configuration to wezterm
return config
