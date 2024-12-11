{ pkgs, lib, config, inputs, ... }: {

  imports = [
    # See https://github.com/NixOS/nixos-hardware/blob/master/flake.nix
    inputs.nixos-hardware.nixosModules.framework-12th-gen-intel
    ./hardware-configuration.nix
  ];

  profile = {
    audio = true;
    bluetooth = true;
    graphical = true;
    battery = true;
    virtual = false;
    virtualHost = true;
  };

  activities = {
    coding = true;
    gaming = false;
    djing = false;
    jamming = false;
  };

  age.secrets = {
    pvpn-fast-wg-quick-config.file = ../../secrets/framework-pvpn-fast-wg-quick-config.age;
  };

  services = {
    syncthing = {
      enable = true;
    };
    getty.autologinUser = config.admin.username;

    jellyfin = {
      enable = true;
      openFirewall = true;
    };
  };

  systemd.tmpfiles.rules = [
    "d /jellyfin 0755 jellyfin jellyfin -"
  ];

  fileSystems = {
    "/jellyfin" = {
      device = "/archive/videos";
      options = [ "ro" "bind" "nofail" "noatime" ];
    };
    "/archive" = {
      device = "/dev/disk/by-uuid/fabb5a38-c104-4e34-8652-04864df28799";
      fsType = "btrfs";
      options = [ "nofail" "noatime" ];
    };
  };

  # Needed to create Rasp Pi SD images
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Enable swap on luks
  boot.initrd.luks.devices."luks-b9dd46eb-7a5b-47c6-85da-7ee933c9909a".device = "/dev/disk/by-uuid/b9dd46eb-7a5b-47c6-85da-7ee933c9909a";

  # Fix brightness keys not working
  boot.kernelParams = [ "module_blacklist=hid_sensor_hub" ];

  networking = {
    firewall = {
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
    wg-quick.interfaces = {
      pvpn-fast = {
        configFile = config.age.secrets.pvpn-fast-wg-quick-config.path;
        autostart = false;
      };
    };
  };

  system.stateVersion = "23.11";

}
