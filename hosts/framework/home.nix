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
      pkgs.unstable.bitwig-studio
      pkgs.musescore
      pkgs.lsp-plugins
      pkgs.graillon-free
      pkgs.yabridge
      pkgs.yabridgectl
      pkgs.wineWowPackages.stagingFull
      pkgs.oxefmsynth
      pkgs.surge
      pkgs.surge-XT
      pkgs.vital
      pkgs.synthv1
      pkgs.sorcer
      pkgs.odin2
      pkgs.adlplug
      pkgs.opnplug
      # pkgs.davinci-resolve not working
    ];
  };
}
