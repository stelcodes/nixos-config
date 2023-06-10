{ pkgs, ... }: {

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
}
