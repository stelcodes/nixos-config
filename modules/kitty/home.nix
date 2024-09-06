{ pkgs, ... } : {
  programs.kitty = {
    enable = true;
    font = {
      name = "FiraMono Nerd Font";
      size = 13;
    };
    theme = "Nord";
    settings = {
      shell = "${pkgs.fish}/bin/fish";
      shell_integration = "no-cursor";
      disable_ligatures = "never";
      cursor_shape = "block";
      cursor_blink_interval = 0;
      scrollback_lines = 3000;
      scrollback_pager = "less --chop-long-lines --RAW-CONTROL-CHARS +INPUT_LINE_NUMBER";
      scrollback_pager_history_size = 20;
      wheel_scroll_multiplier = 5;
      touch_scroll_multiplier = 1;
      enable_audio_bell = "no";
      tab_bar_edge = "bottom";
      tab_bar_margin_width = 0;
      tab_bar_style = "fade";
      tab_bar_min_tabs = 2;
      active_tab_foreground = "#aeb3bb";
      active_tab_background = "#434c5e";
      active_tab_font_style = "bold";
      inactive_tab_foreground = "#68809a";
      inactive_tab_background = "#373e4d";
      kitty_mod = "alt";
      allow_remote_control = "no";
      listen_on = "unix:/tmp/kitty";
      enabled_layouts = "splits";
    };
    keybindings = {
      "ctrl+shift+c" = "send_text all \\x03";
      "ctrl+c" = "copy_to_clipboard";
      "ctrl+v" = "paste_from_clipboard";
      "kitty_mod+enter" = "new_os_window_with_cwd";
      "kitty_mod+t" = "new_tab_with_cwd !neighbor";
      "kitty_mod+l" = "next_tab";
      "kitty_mod+h" = "previous_tab";
      "kitty_mod+shift+t" = "set_tab_title";
      "kitty_mod+shift+l" = "move_tab_forward";
      "kitty_mod+shift+h" = "move_tab_backward";
      "kitty_mod+k" = "scroll_line_up";
      "kitty_mod+j" = "scroll_line_down";
      "kitty_mod+u" = "scroll_to_prompt -1";
      "kitty_mod+d" = "scroll_to_prompt 1";
      "kitty_mod+p" = "show_scrollback";
      "kitty_mod+up" = "scroll_page_up";
      "kitty_mod+down" = "scroll_page_down";
      "kitty_mod+equal" = "change_font_size all 13.0";
      "kitty_mod+plus" = "change_font_size all +0.5";
      "kitty_mod+minus" = "change_font_size all -0.5";
    };
  };
}
