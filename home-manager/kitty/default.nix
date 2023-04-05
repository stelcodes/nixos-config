pkgs: {
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrains Mono Nerd Font";
      # name = "OpenDyslexicMono Nerd Font";
      size = 13;
    };
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
      tab_bar_style = "powerline";
      tab_powerline_style = "round";
      tab_bar_min_tabs = 1;
      kitty_mod = "alt";
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
    };
    extraConfig = builtins.readFile ./nord.conf;
  };
}
