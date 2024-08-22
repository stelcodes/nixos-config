{ inputs, pkgs, lib, config, ... }: {

  home = {
    packages = (lib.lists.optionals config.activities.jamming [
      # inputs.audio-nix.packages.${pkgs.system}.bitwig-studio5-latest
      pkgs.unstable.bitwig-studio
      pkgs.audacity
      pkgs.distrho
      pkgs.musescore
      # pkgs.lsp-plugins
      pkgs.graillon-free
      pkgs.yabridge
      pkgs.yabridgectl
      pkgs.wineWowPackages.full
      pkgs.winetricks
      pkgs.oxefmsynth
      pkgs.surge
      pkgs.surge-XT
      pkgs.vital
      pkgs.synthv1
      pkgs.sorcer
      pkgs.odin2
      pkgs.adlplug
      pkgs.opnplug
      pkgs.dragonfly-reverb
      # pkgs.davinci-resolve not working
    ]) ++ (lib.lists.optionals config.activities.djing [
      pkgs.unstable.mixxx
    ]);
  };
}
