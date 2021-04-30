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
    doas = {
      enable = true;
      extraRules = [{
        users = [ "stel" ];
        keepEnv = true;
        noPass = true;
        # persist = true;
      }];
    };
    sudo.enable = false;
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

  # Set your time zone.
  time.timeZone = "America/Detroit";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    font = "Lat2-Terminus16";
    # keyMap = "us";
    useXkbConfig = true;
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
    mutableUsers = true;
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users = {
      stel = {
        home = "/home/stel";
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" "jackaudio" "audio" ];
      };
      wtpof = {
        description = "We The People Opportunity Farm";
        isSystemUser = true;
        home = "/home/wtpof";
        createHome = true;
        packages = [ pkgs.nodejs pkgs.sqlite ];
        shell = pkgs.bashInteractive;
      };
    };
  };

  fonts = {
    fontconfig = { enable = true; };
    fonts =
      [ (pkgs.nerdfonts.override { fonts = [ "Noto" ]; }) pkgs.font-awesome ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [ zsh neovim ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

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
        (import /home/stel/config/home-manager/tmux pkgs)
        (import /home/stel/config/home-manager/zsh pkgs)
        (import /home/stel/config/home-manager/neovim pkgs)
        (import /home/stel/config/home-manager/sway pkgs config)
        (import /home/stel/config/home-manager/git pkgs)
        {
          # Home Manager needs a bit of information about you and the
          # paths it should manage.

          # nixpkgs.config.allowUnfree = true;

          home.packages = [

            # Programming Languages

            # (pkgs.python3.withPackages (py-pkgs: [py-pkgs.swaytools])) this would work but swaytools isn't in the nixos python modules
            pkgs.python39
            pkgs.python39Packages.pip
            # pip packages: swaytools

            # Other package managers
            pkgs.rustup
            # Run this:
            # rustup toolchain install stable
            # cargo install <package>

            pkgs.clojure
            pkgs.nodejs
            pkgs.just
            pkgs.sqlite

            pkgs.babashka
            pkgs.clj-kondo
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
          programs = {

            # Just doesn't work. Getting permission denied error when it tries to read .config/gh
            # gh.enable = true;

            go = { enable = true; };

            direnv = {
              enable = true;
              # I wish I could get nix-shell to work with clojure but it's just too buggy.
              # The issue: when I include pkgs.clojure in nix.shell and try to run aliased commands out of my deps.edn,
              # it errors with any alias using the :extra-paths.
              # enableNixDirenvIntegration = true;
            };

            alacritty = { enable = true; };

            rtorrent = { enable = true; };

            fzf = let
              fzfExcludes = [
                ".local"
                ".cache"
                "*photoslibrary"
                ".git"
                "node_modules"
                "Library"
                ".rustup"
                ".cargo"
                ".m2"
                ".bash_history"
              ];
              # string lib found here https://git.io/JtIua
              fzfExcludesString =
                pkgs.lib.concatMapStrings (glob: " --exclude '${glob}'")
                fzfExcludes;
            in {
              enable = true;
              defaultOptions = [ "--height 80%" "--reverse" ];
              defaultCommand = "fd --type f --hidden ${fzfExcludesString}";
              changeDirWidgetCommand =
                "fd --type d --hidden ${fzfExcludesString}";
              # I got tripped up because home.sessionVariables do NOT get updated with zsh sourcing.
              # They only get updated by restarting terminal, this is by design from the nix devs
              # See https://git.io/JtIuV
            };
          };

          xdg.configFile = {
            "alacritty/alacritty.yml".text = pkgs.lib.mkMerge [
              ''
                shell:
                  program: ${pkgs.zsh}/bin/zsh''
              (builtins.readFile /home/stel/config/misc/alacritty-base.yml)
              (builtins.readFile /home/stel/config/misc/alacritty-nord.yml)
            ];

            # I'm having a weird bug where clj -X:new gives an error about :exec-fn not being set even though it's set...
            # So I'm trying to put the deps.edn in the .config directory as well as the .clojure directory
            # I don't think this helped I had to use clj -X:new:clj-new/create
            "clojure/deps.edn".source = /home/stel/config/misc/deps.edn;
          };

        }
      ];
  };
}

