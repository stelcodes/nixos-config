{
  # nix-repl> :lf .
  # nix-repl> pkgs = import inputs.nixpkgs { system = builtins.currentSystem; }

  description = "My Personal NixOS System Flake Configuration";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      # url = "github:nix-community/home-manager/release-24.11";
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    disko = {
      url = "github:nix-community/disko";
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
    yazi-plugins = {
      url = "github:yazi-rs/plugins";
      flake = false;
    };
    starship-yazi = {
      url = "github:Rolv-Apneseth/starship.yazi";
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
    catppuccin-btop = {
      url = "github:catppuccin/btop";
      flake = false;
    };
    nvim-origami = {
      url = "github:chrisgrieser/nvim-origami";
      flake = false;
    };
    workspace-diagnostics-nvim = {
      url = "github:artemave/workspace-diagnostics.nvim";
      flake = false;
    };
    flake-registry = {
      url = "github:nixos/flake-registry";
      flake = false;
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
        # nix build .#nixosConfigurations.boko.config.formats.sd-aarch64 (build is failing atm)
        # https://hydra.nixos.org/job/nixos/trunk-combined/nixos.sd_image.aarch64-linux
        # https://nix.dev/tutorials/nixos/installing-nixos-on-a-raspberry-pi.html
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
