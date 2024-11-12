{ inputs, pkgs, lib, config, ... }: {

  home = {
    packages =
      # I don't really make music on Linux anymore bc it's way too hard
      (lib.lists.optionals (pkgs.stdenv.isLinux && config.activities.jamming) [
        pkgs.unstable.bitwig-studio
        pkgs.audacity
        pkgs.distrho
        pkgs.musescore
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
      ]) ++ (lib.lists.optionals config.activities.djing [
        pkgs.ffmpeg
        pkgs.convert-audio
        pkgs.rekordbox-add
      ]);
  };
}
