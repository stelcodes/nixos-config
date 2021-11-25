{ config, pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;

  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    /config/modules/laptop
    /config/modules/postgresql/local.nix
    /config/modules/clojure
    /config/modules/python
    /config/modules/nodejs
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [ "wl" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  boot.extraModprobeConfig = ''
    options snd-hda-intel model=mba6
  '';

  networking.hostName = "azul"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.enableIPv6 = true;
  networking.useDHCP = false;

  hardware.facetimehd.enable = true;

  users.users.stel.extraGroups = [ "networkmanager" ];

  # doas chown -R stel:nginx /www
  # Each time I add something to /www I should run this command because nginx needs group
  # permission in order to serve files
  services.nginx.enable = true;
  services.nginx.recommendedGzipSettings = true;
  services.nginx.recommendedOptimisation = true;
  services.nginx.recommendedProxySettings = true;
  services.nginx.recommendedTlsSettings = true;
  services.nginx.virtualHosts = {
    "dev-blog-published.lh".locations."/".root = "/www/dev-blog-published";
    "dev-blog-preview.lh".locations."/".root = "/www/dev-blog-preview";
    "dev-blog-development.lh".locations."/".proxyPass = "http://localhost:3000";
    "grip.lh".locations."/".proxyPass = "http://localhost:6419";
    "directus.lh".locations."/".proxyPass = "http://localhost:8055";
  };

  environment.systemPackages =
    let unstable = import <nixos-unstable> { config.allowUnfree = true; };
    in with pkgs; [
      # SOCIAL
      slack
      discord
      # MEDIA
      calibre
      evince
      gimp
      youtube-dl
      mpv-unwrapped
      unstable.obs-studio
      qbittorrent
      # BROWSERS
      firefox # allow dns over https
      unstable.tor-browser-bundle-bin
      # MUSIC
      spotify
      # CODING
      jq
      yq
      rlwrap
      glow
      unstable.chroma
      rustup
      # unstable.android-studio
      usbutils # for lsusb
    ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}

