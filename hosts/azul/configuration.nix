# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  # From https://github.com/NixOS/nixpkgs/issues/15162
  nixpkgs.config.allowUnfree = true;

  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    #<home-manager/nixos>
    /home/stel/config/modules/common.nix
    /home/stel/config/modules/postgresql-local.nix
    # using a channel for home-manager becuse that's what the docs say to do
    # I could also use a flake but that would require a day to tinker with
    # I do want to use flakes eventually. Home-manager README has a good flake example.
    <home-manager/nixos>
  ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelModules = [ "wl" ];
    extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
    # resumeDevice = "/dev/sda2";
  };

  security = {
    pam.services.swaylock = {
      text = ''
        auth include login
      '';
    };
  };

  networking = {
    hostName = "azul"; # Define your hostname.
    networkmanager.enable = true;
    # networking.wireless.userControlled = true;
    wireless.enable = false; # Enables wireless support via wpa_supplicant.
    nameservers = [ "8.8.8.8" "208.67.222.222" "1.1.1.1" "9.9.9.9" ];
    # this should definitely be off
    enableIPv6 = false;
    # this should definitely be off
    useDHCP = false;
    # this should definitely be off (maybe) lol
    interfaces.wlp3s0.useDHCP = false;
  };

  # Enable sound.
  sound.enable = true;

  hardware = {
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull.override { jackaudioSupport = true; };
    };
    facetimehd.enable = true;
    bluetooth.enable = true;
    opengl.enable = true;
  };

  location = {
    latitude = 42.2;
    longitude = -83.6;
  };

  users.users.test = {
    isNormalUser = true;
    shell = pkgs.zsh;
  };

  # Need this for font-manager or any other gtk app to work I guess
  programs.dconf.enable = true;

  services = {
    # Enable CUPS to print documents.
    printing.enable = true;

    # Enable iOS devices to automatically connect
    # Use idevice* commands like ideviceinfo
    usbmuxd.enable = true;

    blueman.enable = true;
    gnome.gnome-keyring.enable = true;

    postgresql = {
      ensureDatabases = [ "cuternews" "dev_blog" ];
      ensureUsers = [
        {
          name = "dev_blog_directus";
          ensurePermissions = { "DATABASE dev_blog" = "ALL PRIVILEGES"; };
        }
        {
          name = "static_site_builder";
          ensurePermissions = { "ALL TABLES IN SCHEMA public" = "SELECT"; };
          # GRANT SELECT ON ALL TABLES IN SCHEMA public TO static_site_builder;
          # This allows the user to read all tables in the default public schema. BUT not tables created after
          # this command was run.
          # Schema's are basically namespaces for tables in postgres
          # The above command works for old tables, but static_site_builder doesn't have permission for new tables
          # We need to change the default privileges for objects created by dev_blog_directus.
          # The way default privileges work in postgres is this: only a user can change their own default privileges
          # on *their own* objects. So the dev_blog_directus user has to change their default privileges to allow
          # static_site_builder to SELECT on new dev_blog_directus tables.
          # As dev_blog_directus user:
          # ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO static_site_builder;
        }
      ];
      # extraPlugins = [ pkgs.postgresql_13.pkgs.postgis ];
    };

    # don’t shutdown when power button is short-pressed
    logind.extraConfig = "HandlePowerKey=ignore";
    dnsmasq = {
      enable = true;
      extraConfig = "address=/lh/127.0.0.1";
    };

    # doas chown -R stel:nginx /www
    # Each time I add something to /www I should run this command because nginx needs group
    # permission in order to serve files
    nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      virtualHosts = {
        "dev-blog-published.lh".locations."/".root = "/www/dev-blog-published";
        "dev-blog-preview.lh".locations."/".root = "/www/dev-blog-preview";
        "dev-blog-development.lh".locations."/".proxyPass =
          "http://localhost:3000";
        "grip.lh".locations."/".proxyPass = "http://localhost:6419";
        "directus.lh".locations."/".proxyPass = "http://localhost:8055";
      };
    };
  };

  fonts = {
    fontconfig = {
      enable = true;
      # https://git.io/Js0vT
      defaultFonts = {
        emoji =
          [ "Noto Color Emoji" "Font Awesome 5 Free" "Font Awesome 5 Brands" ];
        # For Alacritty
        monospace = [
          "Noto Sans Mono"
          "Noto Color Emoji"
          "Font Awesome 5 Free"
          "Font Awesome 5 Brands"
        ];
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
      };
    };
    fonts = [
      pkgs.font-awesome
      pkgs.noto-fonts-emoji
      pkgs.noto-fonts
      pkgs.powerline-fonts
      # (pkgs.nerdfonts.override { fonts = [ "Noto" ]; })
    ];
  };

  environment.systemPackages = with pkgs; [
    etcher
    gparted
    tor-browser-bundle-bin
    discord
    # proton vpn
    protonvpn-cli
    calibre

    #art
    gimp
    # ardour

    #printing
    hplip
    evince # pdf viewer
    pdfarranger

    # media
    youtube-dl
    shotcut
    mpv-unwrapped
    # qjackctl
    # a2jmidid
    # cadence

    qbittorrent

    # browsers

    # Firefox settings:
    # allow dns over https
    # no proxy
    firefox
    ungoogled-chromium

    # upower
    dbus

    # music
    spotify

    # office

    # Takes way too long to build
    # libreoffice

    #email
    thunderbird
    protonmail-bridge

    # partitioning
    gnome.gnome-disk-utility

    # recording/streaming
    obs-studio
    obs-wlrobs
    libsForQt5.qt5.qtwayland
    pavucontrol

    # graalvm11-ce
    # For iphone hotspot tethering
    libimobiledevice

    slack
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
        (import /home/stel/config/home-manager pkgs)
        (import /home/stel/config/home-manager/alacritty pkgs)
        (import /home/stel/config/home-manager/sway pkgs config)
        (import /home/stel/config/home-manager/python pkgs)
        (import /home/stel/config/home-manager/rust pkgs)
        (import /home/stel/config/home-manager/go pkgs)
        (import /home/stel/config/home-manager/nodejs pkgs)
        (import /home/stel/config/home-manager/clojure pkgs)
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

