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
}
