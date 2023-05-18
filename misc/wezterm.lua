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
-- config.font = wezterm.font { family = "NotoSansM Nerd Font Mono" };
config.font = wezterm.font { family = "FiraMono Nerd Font Mono" };

config.disable_default_key_bindings = true
config.tab_bar_at_bottom = true

config.alternate_buffer_wheel_scroll_speed = 1;

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
    key = 'v',
    mods = 'CTRL',
    action = wezterm.action.PasteFrom 'Clipboard',
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
        { Text = 'New workspace' },
      },
      action = wezterm.action_callback(function(window, pane, line)
        if line and line ~= '' then
          window:perform_action(wezterm.action.SwitchToWorkspace { name = line }, pane)
        end
      end),
    },
  },
  {
    key = 'r',
    mods = 'ALT',
    action = wezterm.action.PromptInputLine {
      description = wezterm.format {
        { Attribute = { Intensity = 'Bold' } },
        { Foreground = { AnsiColor = 'Fuchsia' } },
        { Text = 'Rename workspace' },
      },
      action = wezterm.action_callback(function(window, pane, line)
        if line and line ~= '' then
          wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
        end
      end),
    },

  },
  { key = 'D', mods = 'ALT', action = wezterm.action.ShowDebugOverlay },
  { key = 'k', mods = 'ALT', action = wezterm.action.ScrollByLine(-1) },
  { key = 'j', mods = 'ALT', action = wezterm.action.ScrollByLine(1) },
}

for i = 1, 8 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'ALT',
    action = wezterm.action.ActivateTab(i - 1),
  })
end

wezterm.on('update-right-status', function(window, pane)
  -- local date = wezterm.strftime '%Y-%m-%d %H:%M:%S'
  local mw = window:mux_window()

  -- Make it italic and underlined
  window:set_right_status(wezterm.format {
    -- { Attribute = { Underline = 'Single' } },
    -- { Attribute = { Italic = true } },
    { Text = mw:get_workspace() },
  })
end)

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
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

config.unix_domains = { { name = 'unix' } }
config.default_gui_startup_args = { "connect", "unix" }

config.show_new_tab_button_in_tab_bar = false
config.mouse_wheel_scrolls_tabs = false

config.debug_key_events = true

-- and finally, return the configuration to wezterm
return config
