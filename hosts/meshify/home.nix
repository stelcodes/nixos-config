{ pkgs, ... }: {
  imports = [
    ../../modules/common/home.nix
    ../../modules/graphical/home.nix
    ../../modules/vscode/home.nix
  ];

  home.packages = [
    pkgs.musescore
    pkgs.bitwig-studio
    pkgs.graillon-free
  ];
}
