{ pkgs, ... }: {
  imports = [ ../common ];
  config = {

    # Set your time zone.
    time.timeZone = "America/Detroit";

    networking.firewall.allowPing = true;

    services.openssh.enable = true;
    services.openssh.passwordAuthentication = false;
  };
}
