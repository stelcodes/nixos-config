{ pkgs, ... }: {
  imports = [ ../common ];
  config = {
    networking.firewall.allowPing = true;

    services.openssh.enable = true;
    services.openssh.passwordAuthentication = false;
  };
}
