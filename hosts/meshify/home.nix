{ pkgs, inputs, system, ... }: {
  imports = [
    ../../modules/vscode/home.nix
  ];

  home.stateVersion = "23.05";

  home.packages = [
    pkgs.musescore
    pkgs.bitwig-studio
    pkgs.graillon-free
    pkgs.mixxx
    pkgs.kodi-wayland
    pkgs.audacity
    pkgs.ffmpeg
    pkgs.fractal
    inputs.gpt4all-nix.packages.${system}.default
  ];
}
