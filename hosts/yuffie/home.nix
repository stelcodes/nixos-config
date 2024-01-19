{ pkgs, ... }: {

  home = {
    sessionVariables = {
      STEAM_FORCE_DESKTOPUI_SCALING = 2;
    };
    stateVersion = "23.11";
    packages = [
      # pkgs.davinci-resolve not working
      pkgs.obsidian
      pkgs.discord-firefox
      pkgs.signal-desktop
      pkgs.retroarch-loaded
    ];
  };
  wayland.windowManager.sway = {
    wallpaper = pkgs.fetchurl {
      url = "https://i.imgur.com/lR2iapT.jpg";
      hash = "sha256-JtY6vWns88mZ29fuYBYZO1NoD+O1YxPb9EBfotv7yb0=";
    };
  };
}
