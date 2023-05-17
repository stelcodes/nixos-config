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
  boot.initrd.luks.devices."luks-b9dd46eb-7a5b-47c6-85da-7ee933c9909a".device = "/dev/disk/by-uuid/b9dd46eb-7a5b-47c6-85da-7ee933c9909a";
  boot.initrd.luks.devices."luks-b9dd46eb-7a5b-47c6-85da-7ee933c9909a".keyFile = "/crypto_keyfile.bin";

  # Fix brightness keys not working
  boot.kernelParams = [ "module_blacklist=hid_sensor_hub" ];

  networking.hostName = hostName;
  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];

  system.stateVersion = "23.05";

}
