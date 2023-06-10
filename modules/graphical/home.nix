{ pkgs, lib, ... }: {

  gtk = {
    enable = true;
    font = {
      name = "FiraMono Nerd Font";
      size = 10;
    };
    theme = {
      package = pkgs.nordic;
      name = "Nordic";
    };
    iconTheme = {
      package = pkgs.nordzy-icon-theme;
      name = "Nordzy";
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-theme-name = "Nordic";
      gtk-icon-theme-name = "Nordzy";
      gtk-cursor-theme-name = "Nordzy-cursors";
    };
  };

  home.pointerCursor = {
    package = pkgs.nordzy-cursor-theme;
    name = "Nordzy-cursors";
    # Sway seems unaffected by this size and defaults to 24
    size = 24;
    gtk.enable = true;
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
  };

  # I'm using nemo (comes with cinnamon) instead of dolphin now
  # https://wiki.archlinux.org/title/Dolphin#Mismatched_folder_view_background_colors
  xdg.configFile.kdeglobals.text = ''
    [Colors:View]
    BackgroundNormal=#2e3440
  '';

  dconf.settings =
    with lib.hm.gvariant;
    let bind = x: mkArray type.string [ x ];
    in
    {
      "org/cinnamon" = {
        alttab-switcher-delay = mkInt32 0;
        hotcorner-layout = mkArray type.string [
          "expo:true:0"
          ":false:0"
          ":false:0"
          ":false:0"
        ];
      };
      "org/cinnamon/theme" = {
        name = "Nordic";
      };
      "org/cinnamon/sounds" = {
        notification-enabled = false;
      };
      "org/cinnamon/desktop/keybindings/wm" = {
        close = bind "<Shift><Super>q";
        move-to-workspace-left = bind "<Shift><Super>h";
        move-to-workspace-right = bind "<Shift><Super>l";
        switch-to-workspace-left = bind "<Super>h";
        switch-to-workspace-right = bind "<Super>l";
        switch-windows = bind "<Super>Tab";
        toggle-fullscreen = bind "<Super>Space";
        show-desktop = bind "<Super>x";
      };
      "org/cinnamon/desktop/keybindings/media-keys" = {
        logout = bind "<Shift><Super>e";
        terminal = bind "<Super>Return";
        www = bind "<Super>BackSpace";
        screensaver = bind "<Super>Delete";
        home = bind "<Super>f";
      };
      "org/cinnamon/desktop/wm/preferences" = {
        # titlebar-font = "FiraMono Nerd Font Medium 10";
      };
      "org/cinnamon/desktop/interface" = {
        cursor-size = "24";
        cursor-theme = "Nordzy-cursors";
        # ubuntu medium 10 is default
        # font-name = "FiraMono Nerd Font 11";
        gtk-theme = "Nordic";
        icon-theme = "Nordzy";
      };
      "org/cinnamon/desktop/applications/terminal" = {
        exec = "${pkgs.wezterm}/bin/wezterm";
      };

      # Menu settings are not stored in dconf database >.>"
      # They're kept in a json file at .config/cinnamon/spices/menu@cinnamon.org/
      # They can be changed by right clicking the menu icon -> configure
      # I'm just manually set <Super>d menu shortcut for now

      # Calendar
      # Same deal
      # Format: %b %e %l:%M %p

      # Maybe set these in the future?
      # org.gnome.desktop.interface
      # org.gnome.desktop.wm.preferences
      # org.cinnamon.desktop.background picture-uri "file://${pkgs.nord-wallpaper}"
    };

}
