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
    /config/modules/i3
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

  security.pam.services.swaylock.text = "auth include login";

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
  # networking.interfaces.wlp3s0.useDHCP = false;
  # networking.interfaces.enp0s20u1c4i2.useDHCP = true;
  # iphone tethering command: exec doas dhcpcd
  # networking.enableIPv6 = true;
  # *.useDHCP = false;
  # doas dhcpcd --waitip --timeout 6000
  # See realtime dhcp logging, will quit when an ip address is given

  # Enable sound.
  sound.enable = true;

  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.facetimehd.enable = true;
  hardware.bluetooth.enable = true;
  hardware.opengl.enable = true;

  location.latitude = 42.2;
  location.longitude = -83.6;

  users.users.stel.extraGroups = [ "networkmanager" "jackaudio" "audio" ];

  # Need this for font-manager or any other gtk app to work I guess
  programs.dconf.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable iOS devices to automatically connect
  # Use idevice* commands like ideviceinfo
  services.usbmuxd.enable = true;

  services.blueman.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # This should trigger "hybrid-sleep" when the battery is critical
  services.upower.enable = true;

  services.pipewire.enable = true;

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

  # don’t shutdown when power button is short-pressed
  services.logind.extraConfig = "HandlePowerKey=ignore";
  services.dnsmasq.enable = true;
  services.dnsmasq.extraConfig = "address=/lh/127.0.0.1";

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

  fonts.fontconfig.enable = true;
  # https://git.io/Js0vT
  fonts.fontconfig.defaultFonts.emoji =
    [ "Noto Color Emoji" "Font Awesome 5 Free" "Font Awesome 5 Brands" ];
  # For Alacritty
  fonts.fontconfig.defaultFonts.monospace = [
    "Noto Sans Mono"
    "Noto Color Emoji"
    "Font Awesome 5 Free"
    "Font Awesome 5 Brands"
  ];
  fonts.fontconfig.defaultFonts.serif = [ "Noto Serif" ];
  fonts.fontconfig.defaultFonts.sansSerif = [ "Noto Sans" ];
  fonts.fonts = [
    pkgs.font-awesome
    pkgs.noto-fonts-emoji
    pkgs.noto-fonts
    pkgs.powerline-fonts
    # (pkgs.nerdfonts.override { fonts = [ "Noto" ]; })
  ];

  environment.systemPackages = let unstable = import <nixos-unstable> { config.allowUnfree = true; };
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
    shotcut
    youtube-dl
    mpv-unwrapped
    unstable.obs-studio
    unstable.zoom-us
    # PRINTING
    hplip
    # TORRENTING
    qbittorrent
    # tor-browser-bundle-bin
    # BROWSERS
    firefox # allow dns over https
    ungoogled-chromium
    # MUSIC
    spotify
    unstable.reaper
    # EMAIL
    thunderbird
    protonmail-bridge
    # DISKS
    gnome.gnome-disk-utility
    etcher
    gparted
    # IDK
    dbus
    # DATA PROCESSING
    jq
    yq
    dhcpcd
    audacity
    pavucontrol
    rlwrap
    glow
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}

