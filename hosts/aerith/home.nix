{ pkgs, ... }: {
  home = {
    stateVersion = "23.11";
    packages = [
      pkgs.obsidian
      pkgs.spotify
    ];
  };

  wayland.windowManager.sway = {
    mainDisplay = "eDP-1";
    sleep = {
      preferredType = "hybrid-sleep";
      lockBefore = false;
      auto = {
        enable = true;
        idleMinutes = 15;
      };
    };
    wallpaper = pkgs.wallpaper.rei-moon;
  };
}
