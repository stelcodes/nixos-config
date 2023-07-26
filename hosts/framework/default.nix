{ hostName, pkgs, inputs, ... }: {

  imports = [
    ./hardware-configuration.nix
    ../../modules/common
    ../../modules/graphical
    ../../modules/laptop
    inputs.musnix.nixosModules.musnix
  ];

  services.xserver.xkbOptions = "caps:escape,altwin:swap_alt_win";

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
    pkgs.qpwgraph
    pkgs.reaper
    pkgs.autotalent
    pkgs.talentedhack
    pkgs.distrho
    pkgs.musescore
    pkgs.ffmpeg_6
    pkgs.bitwig-studio
    pkgs.lsp-plugins
    inputs.nix-alien.packages.x86_64-linux.nix-alien
    pkgs.graillon-free
    # pkgs.davinci-resolve not working
    pkgs.yabridge
    pkgs.yabridgectl
    pkgs.wineWowPackages.stagingFull
    pkgs._86Box
  ];

  virtualisation.virtualbox.host.enable = true;

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
