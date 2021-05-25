{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix # generated at runtime by nixos-infect
    /home/stel/config/modules/common.nix
    <home-manager/nixos>
  ];

  boot.cleanTmpDir = true;

  networking.hostName = "morado1";
  networking.firewall.allowPing = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;

  users.users.stel.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFl1QCu19AUDFaaZZAt4YtnxxdX+JDvDz5rdnBEfH/Bb stel@azul"
  ];

  home-manager = {
    useGlobalPkgs = true;
    users.stel = { config, ... }:
      pkgs.lib.mkMerge [ (import /home/stel/config/home-manager pkgs) ];
  };

}
