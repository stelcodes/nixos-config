{
  # nix-repl> :lf .
  # nix-repl> pkgs = import inputs.nixpkgs { system = builtins.currentSystem; }

  description = "My Personal NixOS System Flake Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    audio-nix = {
      url = "github:polygon/audio.nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    home-manager = {
      # User Package Management
      url = "github:nix-community/home-manager/release-24.05";
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
    nnn-plugins = {
      url = "github:jarun/nnn";
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
    wayland-pipewire-idle-inhibit = {
      url = "github:rafaelrc7/wayland-pipewire-idle-inhibit";
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

    homeConfigurations = {
      marlene = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import inputs.nixpkgs { system = "aarch64-darwin"; };
        modules = [
          ./hosts/marlene/home.nix
          ./modules/common/home.nix
          # Only need to import this as a hm module in standalone hm configs
          ./modules/common/nixpkgs.nix
        ];
        extraSpecialArgs = {
          inherit inputs;
        };
      };
    };

    nixosConfigurations =
      let
        nixosMachine = { system, hostName }:
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
        # 2013 macbook air
        aerith = nixosMachine {
          hostName = "aerith";
          system = "x86_64-linux";
        };
        # mac mini 2011 beatrix
        beatrix = nixosMachine {
          hostName = "beatrix";
          system = "x86_64-linux";
        };
        # raspberry pi 3B+
        boko = nixosMachine {
          hostName = "boko";
          system = "aarch64-linux";
        };
        # basic virtual machine for experimenting
        sandbox = nixosMachine {
          hostName = "sandbox";
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
