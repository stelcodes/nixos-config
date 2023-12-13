{ pkgs, inputs, ... }: {

  home = {
    stateVersion = "23.05";
    packages = [
      pkgs.musescore
      pkgs.bitwig-studio
      pkgs.graillon-free
      pkgs.mixxx
      pkgs.kodi-wayland
      pkgs.audacity
      pkgs.ffmpeg
      pkgs.fractal
      inputs.gpt4all-nix.packages.${pkgs.system}.default
      pkgs.vscodium
    ];
  };
}
