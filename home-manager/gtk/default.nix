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
}
