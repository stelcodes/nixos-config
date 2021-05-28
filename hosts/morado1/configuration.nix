{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix # generated at runtime by nixos-infect
    /home/stel/config/modules/common.nix
    /home/stel/config/modules/server.nix
    <home-manager/nixos>
  ];

  networking.hostName = "morado1";
  networking.firewall.allowedTCPPorts = [ 22 ];

  home-manager = {
    useGlobalPkgs = true;
    users.stel = { config, ... }:
      pkgs.lib.mkMerge [ (import /home/stel/config/home-manager pkgs) ];
  };

}
