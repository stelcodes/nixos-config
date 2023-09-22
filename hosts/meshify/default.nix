{ pkgs, config, lib, ... }: {

  musnix.enable = true;

  programs.k3b.enable = true;

  age.secrets = {
    pvpn-fast-private-key.file = ../../secrets/meshify/wg/pvpn-fast/private-key.age;
    pvpn-fast-public-key.file = ../../secrets/meshify/wg/pvpn-fast/public-key.age;
    pvpn-fast-endpoint.file = ../../secrets/meshify/wg/pvpn-fast/endpoint.age;
    pvpn-secure-private-key.file = ../../secrets/meshify/wg/pvpn-secure/private-key.age;
    pvpn-secure-public-key.file = ../../secrets/meshify/wg/pvpn-secure/public-key.age;
    pvpn-secure-endpoint.file = ../../secrets/meshify/wg/pvpn-secure/endpoint.age;
  };

  networking.vpnConnections = {
    pvpn-fast = {
      enable = true;
      autostart = true;
      killswitch = true;
      privateKeyFile = builtins.toString config.age.secrets.pvpn-fast-private-key.path;
      endpoint = {
        # Requires two rebuilds which is annoying but works!
        publicKey = lib.fileContents config.age.secrets.pvpn-fast-public-key.path;
        ip = lib.fileContents config.age.secrets.pvpn-fast-endpoint.path;
      };
    };
    pvpn-secure = {
      enable = true;
      autostart = false;
      killswitch = true;
      privateKeyFile = builtins.toString config.age.secrets.pvpn-secure-private-key.path;
      endpoint = {
        publicKey = lib.fileContents config.age.secrets.pvpn-secure-public-key.path;
        ip = lib.fileContents config.age.secrets.pvpn-secure-endpoint.path;
      };
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-9cb8c555-ba9c-4ae7-880f-5b16bf71579d".device = "/dev/disk/by-uuid/9cb8c555-ba9c-4ae7-880f-5b16bf71579d";
  boot.initrd.luks.devices."luks-9cb8c555-ba9c-4ae7-880f-5b16bf71579d".keyFile = "/crypto_keyfile.bin";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
