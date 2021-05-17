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
    (import "${
        builtins.fetchTarball
        "https://github.com/rycee/home-manager/archive/master.tar.gz"
      }/nixos")
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
    nameservers = [ "8.8.8.8" "8.8.4.4" ];
    enableIPv6 = false;

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;
    interfaces.wlp3s0.useDHCP = false;

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Open ports in the firewall.
    # firewall.allowedTCPPorts = [ ... ];
    # firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # firewall.enable = false;
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

  # Need this for font-manager or any other gtk app to work I guess
  programs.dconf.enable = true;

  services = {
    # Enable CUPS to print documents.
    printing.enable = true;

    blueman.enable = true;
    gnome.gnome-keyring.enable = true;

    postgresql = {
      enable = true;
      package = pkgs.postgresql_13;
      enableTCPIP = true;
      port = 5432;
      dataDir = "/data/postgres";
      authentication = pkgs.lib.mkOverride 10 ''
        # I'm setting up postgres such that any local connection to the server is trusted.
        # As long as the server isn't exposed to the internet and my OS security is good, this
        # is fine and recommended by the official postgres docs: https://is.gd/RsMMpx

        # Allow any user on the local system to connect to any database with
        # any database user name using Unix-domain sockets (the default for local
        # connections).
        local all all trust

        # The same using local loopback TCP/IP connections.
        host all all 127.0.0.1/32 trust

        # The same over IPv6.
        host all all ::1/128 trust

        # The same using a host name (would typically cover both IPv4 and IPv6).
        host all all localhost trust
      '';
      # authentication = "";
      ensureDatabases = [ "cuternews" "dev_blog" ];
      ensureUsers = [
        {
          name = "stel";
        }
        # ALTER USER stel WITH SUPERUSER;
        # To change password:
        # ALTER USER <user> WITH PASSWORD '<password>';
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
        localhost = {
          locations."/" = {
            # proxyPass = "http://localhost:3000";
            root = "/www/dev-blog";
          };
        };
      };
    };
  };

  users = {
    users = {
      wtpof = {
        description = "We The People Opportunity Farm";
        isNormalUser = true;
        home = "/home/wtpof";
        createHome = true;
        packages = [ pkgs.nodejs pkgs.sqlite ];
        shell = pkgs.zsh;
      };
    };
  };

  fonts = {
    fontconfig = {
      enable = true;
      # https://git.io/Js0vT
      defaultFonts = {
        emoji = [ "Noto Color Emoji" "Font Awesome 5 Free" ];
        monospace =
          [ "Noto Sans Mono" "Noto Color Emoji" "Font Awesome 5 Free" ];
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
          home.packages = [
            pkgs.tor-browser-bundle-bin
            pkgs.discord
            # proton vpn
            pkgs.protonvpn-cli
            pkgs.calibre
            pkgs.spotify

            #art
            pkgs.gimp
            # pkgs.ardour

            #printing
            pkgs.hplip
            pkgs.evince # pdf viewer
            pkgs.pdfarranger

            # media
            pkgs.youtube-dl
            pkgs.shotcut
            pkgs.mpv-unwrapped
            # pkgs.qjackctl
            # pkgs.a2jmidid
            # pkgs.cadence

            pkgs.qbittorrent
            pkgs.firefox

            # pkgs.upower
            pkgs.dbus

            # music
            # this is a wrapper around spotify so sway can recognize container attributes properly
            pkgs.spotifywm

            # office
            # pkgs.libreoffice

            #email
            pkgs.thunderbird
            pkgs.protonmail-bridge
          ];

        }
      ];
  };
}

