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
