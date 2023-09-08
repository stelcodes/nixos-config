{ pkgs, ... }: {
  imports = [
    ../../modules/vscode/home.nix
  ];

  home.packages = [
    pkgs.musescore
    pkgs.bitwig-studio
    pkgs.graillon-free
    pkgs.mixxx
    pkgs.kodi-wayland
    pkgs.audacity
    pkgs.ffmpeg
  ];
}
