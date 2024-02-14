{ pkgs, lib, config, inputs, ... }: {

  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.agenix.nixosModules.default
    inputs.nixos-generators.nixosModules.all-formats
    ../syncthing
    ../graphical
    ../battery
    ../audio
    ../bluetooth
    ../virtualisation
  ];

  options = {
    profile = {
      graphical = lib.mkOption {
        type = lib.types.bool;
      };
      battery = lib.mkOption {
        type = lib.types.bool;
      };
      virtual = lib.mkOption {
        type = lib.types.bool;
      };
      virtualHost = lib.mkOption {
        type = lib.types.bool;
      };
      audio = lib.mkOption {
        type = lib.types.bool;
      };
      bluetooth = lib.mkOption {
        type = lib.types.bool;
      };
    };
    activities = {
      gaming = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      coding = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      djing = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      jamming = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
    admin.username = lib.mkOption {
      type = lib.types.str;
      default = "stel";
    };
    admin.email = lib.mkOption {
      type = lib.types.str;
      default = "stel@stel.codes";
    };
    theme.name = lib.mkOption {
      type = lib.types.str;
      default = "everforest";
    };
    theme.set = lib.mkOption {
      type = lib.types.attrs;
      default = (import ../../misc/themes.nix pkgs).${config.theme.name};
    };
  };

  config = {

    boot = {
      tmp.cleanOnBoot = true;
      kernelPackages = lib.mkDefault pkgs.linuxPackages_6_1;

      # These boot loader settings are the only thing in new configuration.nix files
      loader = lib.mkIf (!config.profile.virtual) {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
    };

    # Enable networking
    networking = {
      networkmanager = {
        enable = true;
        dns = "systemd-resolved";
      };
      hosts = {
        "127.0.0.1" = [ "lh" ];
      };
    };

    systemd = {
      extraConfig = ''
        [Manager]
        DefaultTimeoutStopSec=10
        DefaultTimeoutAbortSec=10
      '';
    };

    # Set your time zone.
    time.timeZone = lib.mkDefault "America/Los_Angeles";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };

    console = {
      useXkbConfig = true;
      colors = with config.theme.set; [
        bgx
        redx
        greenx
        yellowx
        bluex
        magentax
        cyanx
        fgx
        bg3x # for comments and autosuggestion to pop out
        redx
        greenx
        yellowx
        bluex
        magentax
        cyanx
        fgx
      ];
    };

    security.doas.enable = true;
    security.doas.extraRules = [{
      users = [ config.admin.username ];
      keepEnv = true;
      noPass = true;
      # persist = true;
    }];
    # security.sudo.enable = false;
    # security.acme.email = "stel@stel.codes";
    # security.acme.acceptTerms = true;

    users = {
      groups = {
        multimedia = { };
      };
      mutableUsers = false;
      users = {
        root = {
          password = "password"; # Override with hashedPasswordFile (use mkpasswd)
        };
        ${config.admin.username} = {
          password = "password"; # Override with hashedPasswordFile (use mkpasswd)
          isNormalUser = true;
          # https://wiki.archlinux.org/title/Users_and_groups#Group_list
          extraGroups = [ "networkmanager" "wheel" "tty" "dialout" "audio" "video" "cdrom" "multimedia" "libvirtd" ];
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFl1QCu19AUDFaaZZAt4YtnxxdX+JDvDz5rdnBEfH/Bb stel@azul"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGl9G7SYvJy8+u2AF+Mlez6bwhrNfKclWo9mK6mwtNgJ stel@stel.codes"
          ];
          shell = pkgs.fish;
        };
      };
    };

    programs = {
      fish.enable = true;
      starship = {
        enable = true;
        settings = builtins.fromTOML (builtins.readFile ../../misc/starship.toml);
      };
      nix-ld.enable = config.activities.coding;
    };

    environment = {
      systemPackages = [
        pkgs.vim
        pkgs.neovim
        pkgs.bat
        pkgs.fd
        pkgs.ripgrep
        pkgs.tealdeer
        pkgs.unzip
        pkgs.git
        pkgs.wireguard-tools
        inputs.agenix.packages.${pkgs.system}.default
        pkgs.wg-killswitch
        pkgs.eza
      ];
      etc = {
        # https://www.reddit.com/r/NixOS/comments/16t2njf/small_trick_for_people_using_nixos_with_flakes
        # Useful for seeing exactly what source flake generated this NixOS system generation
        "nixos-generation-source".source = ../..;
      };
    };

    services = {

      fwupd.enable = lib.mkDefault (!config.profile.virtual);

      # Nice to have, required for gnome-disks to work
      udisks2.enable = true;

      logind = {
        lidSwitch = "suspend-then-hibernate";
        extraConfig = ''
          # Don’t shutdown when power button is short-pressed
          HandlePowerKey=hibernate
          InhibitDelayMaxSec=10
        '';
      };

      resolved.enable = true;

      openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
      };

      # TODO: Only enable this for local physical computers
      avahi = {
        enable = true;
        nssmdns = true; # allow local applications to resolve `local.` domains using avahi.
      };

    };

    nixpkgs =
      let
        config = {
          permittedInsecurePackages = [
            "electron-25.9.0"
            "electron-24.8.6"
          ];
          allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
            "obsidian"
            "spotify"
            "bitwig-studio"
            "graillon"
            "steam"
            "steam-original"
            "steam-run"
            "vital"
            "broadcom-sta"
          ];
        };
      in
      {
        inherit config;
        overlays = [
          # https://github.com/NixOS/nixpkgs/issues/263764#issuecomment-1782979513
          (final: prev: {
            obsidian = prev.obsidian.override { electron = final.electron_24; };
          })
          (final: prev: {
            unstable = import inputs.nixpkgs-unstable { inherit config; system = final.system; };
          })
          (import ../../packages/overlay.nix)
        ];
      };

    nix = {
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
      settings = {
        auto-optimise-store = true;
        experimental-features = [ "nix-command" "flakes" ];
      };
      package = pkgs.nixFlakes; # Enable nixFlakes on system
      extraOptions = ''
        warn-dirty = false
      '';
      # Make the nixpkgs flake input be used for various nix commands
      nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
      registry.nixpkgs.flake = inputs.nixpkgs;
    };

    hardware = {
      enableRedistributableFirmware = (!config.profile.virtual);
      cpu.intel.updateMicrocode = (!config.profile.virtual && pkgs.system == "x86_64-linux");
      cpu.amd.updateMicrocode = (!config.profile.virtual);
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {
        inherit inputs;
        systemConfig = config;
      };
      users.${config.admin.username} = {
        imports = [
          ./home.nix
          ../../hosts/${config.networking.hostName}/home.nix
        ];
      };
    };

    virtualisation.vmVariant = {
      profile.virtualHost = lib.mkForce false;
      virtualisation = {
        memorySize = 4096;
        cores = 4;
      };
      boot.initrd.secrets = lib.mkForce { };
      services.syncthing.enable = lib.mkForce false;
      boot.initrd.luks.devices = lib.mkForce { };
      networking.wg-quick.interfaces = lib.mkForce { };
      users.users = {
        root.hashedPassword = lib.mkForce "$y$j9T$GAOQggBNWKTXXoCXQCGiw0$wVVmGFS2rI.9QDGe51MQHYcEr02FqHVJ1alHig9Y475";
        ${config.admin.username}.hashedPassword = lib.mkForce "$y$j9T$GAOQggBNWKTXXoCXQCGiw0$wVVmGFS2rI.9QDGe51MQHYcEr02FqHVJ1alHig9Y475";
      };
    };

    # I could do this to only create generations tied to specific commits but
    # then I couldn't rebuild from a dirty git repo.
    # system.nixos.label =
    #   let
    #     # Tag each generation with Git hash
    #     system.configurationRevision =
    #       if (inputs.self ? rev)
    #       then inputs.self.shortRev
    #       else throw "Refusing to build from a dirty Git tree!";
    #   in
    #   "GitRev.${config.system.configurationRevision}.Rel.${config.system.nixos.release}";

  };
}
