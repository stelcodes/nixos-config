{ pkgs, ... }: {

  imports = [ ../../modules/protonvpn ];

  musnix.enable = true;

  programs.k3b.enable = true;

  services.protonvpn = {
    enable = true;
    autostart = false;
    killswitch = true;
    interface = {
      privateKeyFile = "/root/secrets/protonvpn";
    };
    endpoint = {
      publicKey = "89W7M9F4cBOiyB2Txdg+PQd4H4p45pKqERLY0GmVsTg=";
      ip = "185.159.158.159";
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
  system.stateVersion = "23.05"; # Did you read the comment?

}
