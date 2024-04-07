{ config, ... }: {

  imports = [
    ./hardware-configuration.nix
  ];

  profile = {
    graphical = true;
    battery = true;
  };

  age.secrets = {
    root-password.file = ../../secrets/root-password.age;
    admin-password.file = ../../secrets/admin-password.age;
  };

  users.users = {
    root.hashedPasswordFile = config.age.secrets.root-password.path;
    ${config.admin.username}.hashedPasswordFile = config.age.secrets.admin-password.path;
  };

  services = {
    xserver.xkbOptions = "caps:escape_shifted_capslock";
    syncthing = {
      enable = true;
      selectedFolders = [ "default" "tunes" "notes" ];
    };
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Enable swap on luks
  boot.initrd.luks.devices."luks-aa91d73b-ad89-4d21-8221-0dcdd36b142a".device = "/dev/disk/by-uuid/aa91d73b-ad89-4d21-8221-0dcdd36b142a";
  boot.initrd.luks.devices."luks-aa91d73b-ad89-4d21-8221-0dcdd36b142a".keyFile = "/crypto_keyfile.bin";

  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];

  hardware.facetimehd = {
    enable = true;
    withCalibration = true;
  };

  system.stateVersion = "23.11";
}

