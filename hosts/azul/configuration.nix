{ config, pkgs, ... }: {
  # From https://github.com/NixOS/nixpkgs/issues/15162
  nixpkgs.config.allowUnfree = true;

  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    /home/stel/config/modules/laptop
    /home/stel/config/modules/postgresql/local.nix
    /home/stel/config/modules/clojure
    /home/stel/config/modules/python
    /home/stel/config/modules/nodejs
    # using a channel for home-manager becuse that's what the docs say to do
    # I could also use a flake but that would require a day to tinker with
    # I do want to use flakes eventually. Home-manager README has a good flake example.
    <home-manager/nixos>
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [ "wl" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  # boot.resumeDevice = "/dev/sda2";

  security.pam.services.swaylock.text = "auth include login";

  networking.hostName = "azul"; # Define your hostname.
  networking.networkmanager.enable = true;
  # networking.wireless.userControlled = true;
  networking.wireless.enable =
    false; # Enables wireless support via wpa_supplicant.
  networking.nameservers = [ "8.8.8.8" "208.67.222.222" "1.1.1.1" "9.9.9.9" ];
  # this should definitely be off
  networking.enableIPv6 = false;
  # this should definitely be off
  networking.useDHCP = false;
  # this should definitely be off (maybe) lol
  networking.interfaces.wlp3s0.useDHCP = false;

  # Enable sound.
  sound.enable = true;

  hardware.pulseaudio.enable = true;
  hardware.facetimehd.enable = true;
  hardware.bluetooth.enable = true;
  hardware.opengl.enable = true;

  location.latitude = 42.2;
  location.longitude = -83.6;

  users.users.stel.extraGroups = [ "networkmanager" "jackaudio" "audio" ];
  users.users.test = {
    isNormalUser = true;
    shell = pkgs.zsh;
  };

  # Need this for font-manager or any other gtk app to work I guess
  programs.dconf.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable iOS devices to automatically connect
  # Use idevice* commands like ideviceinfo
  services.usbmuxd.enable = true;

  services.blueman.enable = true;
  services.gnome.gnome-keyring.enable = true;

  services.postgresql.ensureDatabases = [ "cuternews" "dev_blog" ];
  services.postgresql.ensureUsers = [
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

  environment.systemPackages = with pkgs; [
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
    obs-studio
    libsForQt5.qt5.qtwayland
    # PRINTING
    hplip
    # TORRENTING
    qbittorrent
    tor-browser-bundle-bin
    # BROWSERS
    firefox # allow dns over https
    ungoogled-chromium
    # MUSIC
    spotify
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
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

  home-manager = {
    useGlobalPkgs = true;
    users.stel = { config, ... }:
      pkgs.lib.mkMerge [
        (import /home/stel/config/home-manager/alacritty pkgs)
        (import /home/stel/config/home-manager/sway pkgs config)
        {
          xdg.userDirs = {
            enable = true;
            desktop = "$HOME/desktop";
            documents = "$HOME/documents";
            download = "$HOME/downloads";
            music = "$HOME/music";
            pictures = "$HOME/pictures";
            publicShare = "$HOME/public";
            templates = "$HOME/template";
            videos = "$HOME/videos";
          };
          home = {
            username = "stel";
            stateVersion = "21.03";
            # I'm putting all manually installed executables into ~/.local/bin 
            sessionPath = [ "$HOME/.local/bin" ];
          };
          programs.home-manager.enable = true;
        }
      ];
  };
}

