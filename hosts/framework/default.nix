{ pkgs, lib, config, adminName, inputs, ... }: {

  imports = [
    # See https://github.com/NixOS/nixos-hardware/blob/master/flake.nix
    inputs.nixos-hardware.nixosModules.framework-12th-gen-intel
  ];

  age.secrets = {
    root-password.file = ../../secrets/root-password.age;
    admin-password.file = ../../secrets/admin-password.age;
    framework-pvpn-fast-wg-quick-config.file = ../../secrets/framework-pvpn-fast-wg-quick-config.age;
  };

  users.users = {
    root.hashedPasswordFile = config.age.secrets.root-password.path;
    ${adminName}.hashedPasswordFile = config.age.secrets.admin-password.path;
  };

  services = {
    syncthing = {
      enable = true;
      selectedFolders = [ "default" ];
    };
  };

  # https://github.com/musnix/musnix
  musnix = {
    enable = true;
    # Audio starts with beeps and squeaks when soundcard latency is
    # reduced so it's disabled for now (might be driver issue)
    # soundcardPciId = "00:1f.3";
  };

  powerManagement.cpuFreqGovernor = pkgs.lib.mkForce "powersave";

  virtualisation = {
    hostMachineDefaults.enable = true;
    vmVariant = {
      virtualisation = {
        hostMachineDefaults.enable = lib.mkForce false;
        memorySize = 4096;
        cores = 4;
      };
      # age.secrets = lib.mkForce { };
      boot.initrd.secrets = lib.mkForce { };
      services.syncthing.enable = lib.mkForce false;
      boot.initrd.luks.devices = lib.mkForce { };
      networking.wg-quick.interfaces = lib.mkForce { };
      users.users = {
        # root.hashedPasswordFile = lib.mkForce (lib.toString ../../misc/password-hash.txt);
        # ${adminName}.hashedPasswordFile = lib.mkForce (lib.toString ../../misc/password-hash.txt);
        root.hashedPassword = lib.mkForce "$y$j9T$GAOQggBNWKTXXoCXQCGiw0$wVVmGFS2rI.9QDGe51MQHYcEr02FqHVJ1alHig9Y475";
        ${adminName}.hashedPassword = lib.mkForce "$y$j9T$GAOQggBNWKTXXoCXQCGiw0$wVVmGFS2rI.9QDGe51MQHYcEr02FqHVJ1alHig9Y475";
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
  boot.initrd.luks.devices."luks-b9dd46eb-7a5b-47c6-85da-7ee933c9909a".device = "/dev/disk/by-uuid/b9dd46eb-7a5b-47c6-85da-7ee933c9909a";
  boot.initrd.luks.devices."luks-b9dd46eb-7a5b-47c6-85da-7ee933c9909a".keyFile = "/crypto_keyfile.bin";

  # Fix brightness keys not working
  boot.kernelParams = [ "module_blacklist=hid_sensor_hub" ];

  networking = {
    firewall = {
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
    wg-quick.interfaces = {
      pvpn-fast = {
        configFile = config.age.secrets.framework-pvpn-fast-wg-quick-config.path;
        autostart = true;
      };
    };
  };

  system.stateVersion = "23.11";

}
