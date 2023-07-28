{ pkgs, ... }: {
  imports = [
    ../../modules/vscode/home.nix
  ];

  home.packages = [
    pkgs.musescore
    pkgs.bitwig-studio
    pkgs.graillon-free
  ];
}
