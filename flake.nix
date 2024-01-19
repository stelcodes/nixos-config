{
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
    nnn-plugins = {
      type = "github";
      owner = "jarun";
      repo = "nnn";
      ref = "5595d93d29d2474338a9f601d713d395a07a6029";
      flake = false;
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    arcsearch = {
      url = "github:massivebird/arcsearch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: {

    nixosModules = {
      generators-custom-formats = { config, ... }: {
        imports = [ inputs.nixos-generators.nixosModules.all-formats ];
        formatConfigs = {
          install-iso-plasma = { modulesPath, ... }: {
            formatAttr = "isoImage";
            fileExtension = ".iso";
            imports = [ "${toString modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-plasma5.nix" ];
          };
          install-iso-gnome = { modulesPath, ... }: {
            formatAttr = "isoImage";
            fileExtension = ".iso";
            imports = [ "${toString modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix" ];
          };
        };
      };
    };

    nixosConfigurations =
      let
        nixosMachine = { system, hostName, ... }:
          inputs.nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = { inherit inputs; };
            modules = [
              { networking.hostName = hostName; }
              ./modules/common
              ./hosts/${hostName}
            ];
          };
      in
      {
        # 12th gen intel framework laptop
        yuffie = nixosMachine {
          hostName = "yuffie";
          system = "x86_64-linux";
        };
        # desktop tower
        terra = nixosMachine {
          hostName = "terra";
          system = "x86_64-linux";
        };
        # 2013 macbook air yuffie
        macbook = nixosMachine {
          hostName = "macbook";
          system = "x86_64-linux";
        };
        # mac mini 2011 beatrix
        beatrix = nixosMachine {
          hostName = "beatrix";
          system = "x86_64-linux";
        };
        # raspberry pi 3B+
        olette = nixosMachine {
          hostName = "olette";
          system = "aarch64-linux";
        };
        # minimal server build
        minimal = nixosMachine {
          hostName = "minimal";
          system = "x86_64-linux";
        };
        installer = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            inputs.self.nixosModules.generators-custom-formats
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
