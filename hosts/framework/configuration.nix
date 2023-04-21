{ config, pkgs, ... }: {

  # sudo env NIXPKGS_ALLOW_INSECURE=1 NIX_PATH="nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos:nixos-config=/home/stel/nixos-config/hosts/azul/configuration.nix:/nix/var/nix/profiles/per-user/root/channels" nixos-rebuild switch
  # sudo nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager && sudo nix-channel --update

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    <home-manager/nixos>
    ../../modules/common
    ../../modules/laptop
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

  networking.hostName = "framework";
  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];

  hardware.facetimehd.enable = true;

  system.stateVersion = "23.05";

  # HOME MANAGER
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users.stel = { ... }:
    pkgs.lib.mkMerge [
      (import ../../home-manager pkgs)
      (import ../../home-manager/gtk pkgs)
      (import ../../home-manager/zsh pkgs)
      (import ../../home-manager/fish pkgs)
      (import ../../home-manager/tmux pkgs)
      (import ../../home-manager/neovim/new-config.nix pkgs)
      (import ../../home-manager/alacritty pkgs)
      (import ../../home-manager/kitty pkgs)
      (import ../../home-manager/sway pkgs)
      (import ../../home-manager/python pkgs)
      (import ../../home-manager/rust pkgs)
      (import ../../home-manager/go pkgs)
      (import ../../home-manager/nodejs pkgs)
      (import ../../home-manager/clojure pkgs)
      {
        home.stateVersion = "23.05";
        home.username = "stel";
        home.homeDirectory = "/home/stel";
        home.packages = [
          pkgs.protonvpn-cli
        ];
      }
    ];

}
