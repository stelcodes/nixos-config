{ config, pkgs, ... }: { # From https://github.com/NixOS/nixpkgs/issues/15162
  nixpkgs.config.allowUnfree = true;

  # nixpkgs.overlays = let nixos-unstable = import <nixos-unstable> { };
  # in [ (final: prev: { obs-studio = nixos-unstable.obs-studio; }) ];

  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    /config/modules/laptop
    /config/modules/postgresql/local.nix
    /config/modules/clojure
    /config/modules/python
    /config/modules/nodejs
    # /config/modules/i3
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [ "wl" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  boot.extraModprobeConfig = ''
    options snd-hda-intel model=mba6
  '';
  # boot.resumeDevice = "/dev/sda2";

  systemd.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';

  networking.hostName = "azul"; # Define your hostname.
  networking.networkmanager.enable = true;
  environment.etc."NetworkManager/conf.d/broadcom_wl.conf".text = ''
    [device]
    match-device=driver:wlp3s0
    wifi.scan-rand-mac-address=no
  '';
  networking.nameservers = [ "8.8.8.8" "208.67.222.222" "1.1.1.1" "9.9.9.9" ];
  networking.enableIPv6 = true;
  networking.useDHCP = false;

  hardware.facetimehd.enable = true;

  location.latitude = 42.2;
  location.longitude = -83.6;
  users.users.stel.extraGroups = [ "networkmanager" "jackaudio" "audio" ];


  services.postgresql.ensureDatabases = [ "dev_blog" "functional_news" ];
  services.postgresql.ensureUsers = [
    {
      name = "functional_news_app";
      ensurePermissions = { "DATABASE functional_news" = "ALL PRIVILEGES"; };
    }
    {
      name = "dev_blog_directus";
      ensurePermissions = { "DATABASE dev_blog" = "ALL PRIVILEGES"; };
    }
    {
      name = "static_site_builder";
      ensurePermissions = { "ALL TABLES IN SCHEMA public" = "SELECT"; };
      # As dev_blog_directus user:
      # ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO static_site_builder;
    }
  ];

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
      # NETWORKING
      protonvpn-cli
      libimobiledevice # For iphone hotspot tethering
      # BOOKS
      calibre
      evince
      # IMAGES
      gimp
      # VIDEOS
      youtube-dl
      mpv-unwrapped
      vlc
      unstable.obs-studio
      # PRINTING
      hplip
      # TORRENTING
      qbittorrent
      # tor-browser-bundle-bin
      # BROWSERS
      firefox # allow dns over https
      ungoogled-chromium
      unstable.tor-browser-bundle-bin
      # MUSIC
      spotify
      # EMAIL
      thunderbird
      hydroxide
      # DISKS
      gnome.gnome-disk-utility
      etcher
      gparted
      # DATA PROCESSING
      jq
      yq
      dhcpcd
      audacity
      pavucontrol
      rlwrap
      glow
      # unstable.android-studio
      # rustc
      rustup
      keepassxc
      unstable.fcp
    ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}

