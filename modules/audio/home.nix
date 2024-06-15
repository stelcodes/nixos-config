{ inputs, pkgs, lib, systemConfig, ... }: {

  home = {
    packages = (lib.lists.optionals systemConfig.activities.jamming [
      # inputs.audio-nix.packages.${pkgs.system}.bitwig-studio5-latest
      pkgs.bitwig-studio
      pkgs.musescore
      # pkgs.lsp-plugins
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
      pkgs.dragonfly-reverb
      # pkgs.davinci-resolve not working
    ]) ++ (lib.lists.optionals systemConfig.activities.djing [
      pkgs.unstable.mixxx
    ]);
  };
}
