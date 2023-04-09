pkgs: {

  gtk = {
    enable = true;
    font = {
      name = "NotoSans Nerd Font";
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
    # Cursors only display on GTK apps, kind of annoying
    # cursorTheme = {
    #   package = pkgs.nordzy-cursor-theme;
    #   name = "Nordzy-cursors";
    # };
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
  };

  # https://wiki.archlinux.org/title/Dolphin#Mismatched_folder_view_background_colors
  xdg.configFile.kdeglobals.text = ''
    [Colors:View]
    BackgroundNormal=#2e3440
  '';
}
