{
  # https://nixos-and-flakes.thiscute.world
  # https://www.nixhub.io/
  # https://docs.kernel.org/admin-guide/kernel-parameters.html
  # https://nixpk.gs/pr-tracker.html
  # nix-repl> :lf .
  # nix-repl> pkgs = import inputs.nixpkgs { system = builtins.currentSystem; }

  description = "My Personal NixOS System Flake Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      # User Package Management
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    musnix = {
      url = "github:musnix/musnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-index-database.follows = "nix-index-database";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    gpt4all-nix = {
      url = "github:polygon/gpt4all-nix/d80a923ea94c5ef46f507b6a4557093ad9086ef6";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nnn-src = {
      type = "github";
      owner = "jarun";
      repo = "nnn";
      ref = "v4.9";
      flake = false;
    };
    # I'm using the nixpkgs version atm because the flake has messy dependencies
    # telescope-manix = {
    #   url = "github:MrcJkb/telescope-manix/392a883dec9d8ccfb1da3e10d1101ae34e627b97";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Function that tells my flake which to use and what do what to do with the dependencies.
  outputs = inputs:
    let
      mkComputer = { system, hostName, type, ... }:
        inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs hostName type;
          };
          modules = [ ./modules/common ];
        };
    in
    {
      nixosModules = {
        nixos-generate-formats = { config, ... }: {
          imports = [ inputs.nixos-generators.nixosModules.all-formats ];
          nixpkgs.hostPlatform = "x86_64-linux"; # Maybe don't need this?
          formatConfigs = {
            plasma-installer-iso = { modulesPath, ... }: {
              formatAttr = "isoImage";
              fileExtension = ".iso";
              imports = [ "${toString modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-plasma5.nix" ];
            };
            gnome-installer-iso = { modulesPath, ... }: {
              formatAttr = "isoImage";
              fileExtension = ".iso";
              imports = [ "${toString modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix" ];
            };
          };
        };
      };

      nixosConfigurations = {

        ########################################################################
        # framework laptop i5-1240P
        ########################################################################
        framework = mkComputer {
          hostName = "framework";
          system = "x86_64-linux";
          type = "laptop";
        };

        ########################################################################
        # desktop fractal meshify 2 w ryzen 5600x
        ########################################################################
        meshify = mkComputer {
          hostName = "meshify";
          system = "x86_64-linux";
          type = "desktop";
        };


        ########################################################################
        # macbook laptop i7-4650U
        ########################################################################
        macbook = mkComputer {
          hostName = "macbook";
          system = "x86_64-linux";
          type = "laptop";
        };

        # nix build .#nixosConfigurations.installer-base.config.formats.gnome-installer-iso
        # nix build .#nixosConfigurations.installer-base.config.formats.plasma-installer-iso
        installer-base = inputs.nixpkgs-stable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            inputs.self.nixosModules.nixos-generate-formats
            ({ pkgs, config, ... }: {
              nixpkgs.config.allowUnfree = true;
              environment.systemPackages = [ pkgs.git pkgs.neovim ];
              boot = {
                kernelModules = [ "wl" ];
                extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
              };
            })
          ];
        };

      };

    };
}
