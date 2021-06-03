{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix # generated at runtime by nixos-infect
    /config/modules/server
  ];

  networking.hostName = "gitstore";
  networking.firewall.allowedTCPPorts = [ 22 ];

  users.users.git = {
    description = "For serving git repos";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFl1QCu19AUDFaaZZAt4YtnxxdX+JDvDz5rdnBEfH/Bb stel@azul"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBj6nr06BHdwsxcbSgMyPy5e6UghJgY7R9mTdmg4d9hx stel@nube1"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJJJxJN5jyGvdGsGxwxWWw33ecF4lO0j7txQZRiQMTzs stel@gitstore"
    ];
    isNormalUser = true;
  };
}
