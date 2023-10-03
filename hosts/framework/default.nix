{ pkgs, lib, config, adminName, ... }: {

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

  # https://www.kvraudio.com/plugins/instruments/effects/linux/free/most-popular
  environment.systemPackages = [
    pkgs.autotalent
    pkgs.talentedhack
    pkgs.distrho
    pkgs.musescore
    pkgs.ffmpeg_6
    pkgs.bitwig-studio
    pkgs.lsp-plugins
    pkgs.graillon-free
    # pkgs.davinci-resolve not working
    pkgs.yabridge
    pkgs.yabridgectl
    pkgs.wineWowPackages.stagingFull
    pkgs._86Box
    pkgs.virt-manager # https://nixos.wiki/wiki/Virt-manager
  ];

  virtualisation.virtualbox.host.enable = true;
  virtualisation.libvirtd.enable = true;

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
