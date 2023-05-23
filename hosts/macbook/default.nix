{ hostName, ... }: {

  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-aa91d73b-ad89-4d21-8221-0dcdd36b142a".device = "/dev/disk/by-uuid/aa91d73b-ad89-4d21-8221-0dcdd36b142a";
  boot.initrd.luks.devices."luks-aa91d73b-ad89-4d21-8221-0dcdd36b142a".keyFile = "/crypto_keyfile.bin";

  networking.hostName = hostName;
  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];

  hardware.facetimehd.enable = true;

  system.stateVersion = "23.05";
}

