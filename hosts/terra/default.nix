{ pkgs, config, lib, inputs, ... }: {

  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.common-pc-hdd
    ./hardware-configuration.nix
  ];

  profile = {
    audio = true;
    bluetooth = true;
    graphical = true;
    battery = false;
    virtualHost = true;
    server = false;
    virtual = false;
  };

  activities = {
    coding = true;
    gaming = true;
    djing = true;
    jamming = true;
  };

  age.secrets = {
    pvpn-fast-wg-quick-config.file = ../../secrets/meshify-pvpn-fast-wg-quick-config.age;
    pvpn-sc-wg-quick-config.file = ../../secrets/meshify-pvpn-sc-wg-quick-config.age;
    root-password.file = ../../secrets/root-password.age;
    admin-password.file = ../../secrets/admin-password.age;
  };

  users.users = {
    root.hashedPasswordFile = config.age.secrets.root-password.path;
    ${config.admin.username}.hashedPasswordFile = config.age.secrets.admin-password.path;
  };

  programs.k3b.enable = true;

  services = {
    syncthing = {
      enable = true;
      selectedFolders = [ "default" ];
    };
    getty.autologinUser = config.admin.username;
  };


  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
    wg-quick.interfaces = {
      pvpn-fast = {
        configFile = config.age.secrets.pvpn-fast-wg-quick-config.path;
        autostart = false;
      };
      pvpn-sc = {
        configFile = config.age.secrets.pvpn-sc-wg-quick-config.path;
        autostart = false;
      };
    };
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