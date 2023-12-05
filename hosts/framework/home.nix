{ pkgs, ... }: {

  home = {
    sessionVariables = {
      STEAM_FORCE_DESKTOPUI_SCALING = 2;
    };
    stateVersion = "23.11";
    packages = [
      pkgs.vscodium
      pkgs.audacity
      pkgs.mixxx
      pkgs.bitwig-studio
      pkgs.musescore
      pkgs.lsp-plugins
      pkgs.graillon-free
      pkgs.yabridge
      pkgs.yabridgectl
      pkgs.wineWowPackages.stagingFull
      # pkgs.davinci-resolve not working
    ];
  };
}
