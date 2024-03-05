{ pkgs, ... }: {

  home = {
    sessionVariables = {
      STEAM_FORCE_DESKTOPUI_SCALING = 2;
    };
    stateVersion = "23.11";
    packages = [
      # pkgs.davinci-resolve not working
      pkgs.unstable.obsidian
      pkgs.discord-firefox
      pkgs.signal-desktop
      pkgs.retroarch-loaded
    ];
  };
  wayland.windowManager.sway = {
    mainDisplay = "eDP-1";
    sleep = {
      preferredType = "suspend-then-hibernate";
      lockBefore = true;
      auto = {
        enable = true;
        idleMinutes = 15;
      };
    };
    wallpaper = pkgs.wallpaper.anime-girl-coffee;
  };
}
