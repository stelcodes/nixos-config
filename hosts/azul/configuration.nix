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

  services = {
    # Enable CUPS to print documents.
    printing.enable = true;

    blueman.enable = true;
    gnome3.gnome-keyring.enable = true;

    postgresql = {
      enable = true;
      package = pkgs.postgresql_13;
      enableTCPIP = true;
      port = 5432;
      dataDir = "/data/postgres";
      # authentication = pkgs.lib.mkOverride 10 ''
      #   local all all trust
      #   host all all ::1/128 trust
      # '';
      authentication = "";
      ensureDatabases = [ "cuternews" "wtpof" ];
      ensureUsers = [
        {
          name = "stel";
          ensurePermissions = {
            "DATABASE cuternews" = "ALL PRIVILEGES";
            "DATABASE wtpof" = "ALL PRIVILEGES";
          };
        }
        {
          name = "wtpof";
          ensurePermissions = { "DATABASE wtpof" = "ALL PRIVILEGES"; };
        }
      ];
      # extraPlugins = [ pkgs.postgresql_13.pkgs.postgis ];
    };

    # don’t shutdown when power button is short-pressed
    logind.extraConfig = "HandlePowerKey=ignore";

    # jack = {
    #   jackd = {
    #     enable = true;
    #     # from Arch Wiki https://is.gd/RXY6lR
    #     # session = ''
    #     #   jack_control start
    #     #   jack_control ds alsa
    #     #   jack_control dps device hw:HDA
    #     #   jack_control dps rate 48000
    #     #   jack_control dps nperiods 2
    #     #   jack_control dps period 64
    #     #   sleep 10
    #     #   a2j_control --ehw
    #     #   a2j_control --start
    #     #   sleep 10
    #     #   qjackctl &
    #     # '';
    #     session = "";
    #   };
    #   alsa.enable = false;
    #   loopback.enable = true;
    # };
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
    fontconfig = { enable = true; };
    fonts =
      [ (pkgs.nerdfonts.override { fonts = [ "Noto" ]; }) pkgs.font-awesome ];
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
            pkgs.ardour

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
            pkgs.libreoffice

            #email
            pkgs.thunderbird
            pkgs.protonmail-bridge
          ];

        }
      ];
  };
}

