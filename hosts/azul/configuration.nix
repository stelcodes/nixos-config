{ config, pkgs, ... }: {

  # sudo env NIXPKGS_ALLOW_INSECURE=1 NIX_PATH="nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos:nixos-config=/home/stel/nixos-config/hosts/azul/configuration.nix:/nix/var/nix/profiles/per-user/root/channels" nixos-rebuild switch

  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    <home-manager/nixos>
    ../../modules/common
    ../../modules/laptop
    ../../modules/home-manager
    ../../modules/home-manager/tmux
    ../../modules/home-manager/neovim
    ../../modules/home-manager/fish
    # ../../modules/postgresql/local.nix
    # ../../modules/clojure
    # ../../modules/python
    # ../../modules/nodejs
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

  networking.hostName = "azul";
  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];

  hardware.facetimehd.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.desktopManager.gnome.enable = true;

  # HOME MANAGER
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users.stel = { pkgs, config, ... }: {
    programs.fish.enable = true;
    programs.neovim.enable = true;
    home.stateVersion = config.system.stateVersion;
    home.packages = with pkgs; [];
  };


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}

