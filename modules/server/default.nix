{ pkgs, ... }: {
  imports = [ ../common ];
  config = {

    networking.firewall.allowPing = true;

    services.openssh.enable = true;
    services.openssh.passwordAuthentication = false;

    users.users.stel.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFl1QCu19AUDFaaZZAt4YtnxxdX+JDvDz5rdnBEfH/Bb stel@azul"
    ];

  };
}
