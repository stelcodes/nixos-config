{ pkgs, ... }: {

  imports = [
    ./hardware-configuration.nix
    ../../modules/common
    ../../modules/graphical
  ];

}
