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
  };
}
