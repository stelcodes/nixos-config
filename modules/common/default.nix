{ pkgs, lib, config, inputs, adminName, hostName, system, type, ... }: {

  imports =
    let
      extraNixosModules = {
        server = [ ];
        desktop = [ ../graphical ];
        laptop = [ ../graphical ../laptop ];
      };
    in
    [
      inputs.home-manager.nixosModules.home-manager
      inputs.agenix.nixosModules.default
      inputs.musnix.nixosModules.musnix
      ../syncthing
      ../../hosts/${hostName}
      ../../hosts/${hostName}/hardware-configuration.nix
    ] ++ extraNixosModules.${type};

  options = {
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
      kernelPackages = pkgs.linuxPackages_6_1;
    };

    # Enable networking
    networking = {
      hostName = hostName;
      networkmanager.enable = true;
      hosts = {
        "127.0.0.1" = [ "lh" ];
      };
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
      users = [ adminName ];
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
        ${adminName} = {
          password = "password"; # Override with hashedPasswordFile (use mkpasswd)
          isNormalUser = true;
          # https://wiki.archlinux.org/title/Users_and_groups#Group_list
          extraGroups = [ "networkmanager" "wheel" "tty" "dialout" "audio" "video" "cdrom" "multimedia" "libvirtd" ];
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFl1QCu19AUDFaaZZAt4YtnxxdX+JDvDz5rdnBEfH/Bb stel@azul"
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
      nix-ld.enable = true;
    };

    environment = {
      systemPackages = [
        pkgs.vim
        pkgs.neovim
        pkgs.bat
        pkgs.btop
        pkgs.trashy
        pkgs.fd
        pkgs.ripgrep
        pkgs.tealdeer
        pkgs.unzip
        pkgs.git
        pkgs.wireguard-tools
        inputs.agenix.packages.${system}.default
        pkgs.wg-killswitch
        pkgs.jq
        pkgs.eza
        pkgs.vimv-rs
      ];
      etc = {
        # https://www.reddit.com/r/NixOS/comments/16t2njf/small_trick_for_people_using_nixos_with_flakes
        # Useful for seeing exactly what source flake generated this NixOS system generation
        "nixos-generation-source".source = ../..;
      };
    };

    services = {

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

      openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
      };

    };

    nixpkgs =
      let
        config = {
          allowInsecure = true;
          allowUnfree = true;
        };
      in
      {
        inherit config;
        overlays = [
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
        keep-outputs          = true
        keep-derivations      = true
        warn-dirty            = false
      '';
      # Make the nixpkgs flake input be used for various nix commands
      nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
      registry.nixpkgs.flake = inputs.nixpkgs;
    };

    systemd.extraConfig = ''
      [Manager]
      DefaultTimeoutStopSec=10
      DefaultTimeoutAbortSec=10
    '';

    hardware = {
      enableRedistributableFirmware = true;
      cpu.intel.updateMicrocode = true;
      cpu.amd.updateMicrocode = true;
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {
        inherit inputs adminName hostName system;
        systemConfig = config;
      };
      users.${adminName} = {
        imports =
          let
            extraHmModules = {
              server = [ ];
              desktop = [ ../graphical/home.nix ];
              laptop = [ ../graphical/home.nix ];
            };
          in
          [
            ./home.nix
            ../../hosts/${hostName}/home.nix
          ] ++ extraHmModules.${type};
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
