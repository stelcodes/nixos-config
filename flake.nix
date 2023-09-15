{
  description = "My Personal NixOS System Flake Configuration";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; }; # Nix Packages
    home-manager = {
      # User Package Management
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    manix = {
      # Fork with crucial fixes, upstream seems abandoned
      url = "github:kulabun/manix/dfb3bb1164fb6b6c61597c9cb10110cc45e1203d";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  # Function that tells my flake which to use and what do what to do with the dependencies.
  outputs = inputs:
    let
      mkComputer = { system, user, themeName, hostName, type, ... }:
        let
          pkgs = import inputs.nixpkgs { inherit system; };
          themes = import ./misc/themes.nix pkgs;
          theme = themes.${themeName};
          extraNixosModules = {
            server = [ ];
            desktop = [ ./modules/graphical ];
            laptop = [ ./modules/graphical ./modules/laptop ];
          };
          extraHmModules = {
            server = [ ];
            desktop = [ ./modules/graphical/home.nix ];
            laptop = [ ./modules/graphical/home.nix ];
          };
        in
        inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs user theme hostName system;
          };
          modules = [
            ./hosts/${hostName}
            ./hosts/${hostName}/hardware-configuration.nix
            ./modules/common
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit inputs user theme hostName system;
              };
              home-manager.users.${user} = {
                imports = [
                  ./modules/common/home.nix
                  ./hosts/${hostName}/home.nix
                ] ++ extraHmModules.${type};
              };
            }
          ] ++ extraNixosModules.${type};
        };
    in
    {
      nixosConfigurations = {

        ########################################################################
        # framework laptop i5-1240P
        ########################################################################
        framework = mkComputer {
          hostName = "framework";
          system = "x86_64-linux";
          themeName = "everforest";
          type = "laptop";
          user = "stel";
        };

        ########################################################################
        # desktop fractal meshify 2 w ryzen 5600x
        ########################################################################
        meshify = mkComputer {
          hostName = "meshify";
          system = "x86_64-linux";
          themeName = "everforest";
          type = "desktop";
          user = "stel";
        };


        ########################################################################
        # macbook laptop i7-4650U
        ########################################################################
        macbook = mkComputer {
          hostName = "meshify";
          system = "x86_64-linux";
          themeName = "everforest";
          type = "laptop";
          user = "stel";
        };

      };
    };
}
