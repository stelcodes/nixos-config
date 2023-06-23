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
  };

  # Function that tells my flake which to use and what do what to do with the dependencies.
  outputs = inputs:
    let
      # Variables that can be used in the config files.
      user = "stel";
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = {

        ########################################################################
        # framework laptop i5-1240P
        ########################################################################
        framework = inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs user;
            hostName = "framework";
          };
          modules = [
            ./hosts/framework
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit inputs user;
                hostName = "framework";
                mainMonitor = "eDP-1";
              };
              home-manager.users.${user} = {
                imports = [
                  ./hosts/framework/home.nix
                ];
              };
            }
          ];
        };


        ########################################################################
        # macbook laptop i7-4650U
        ########################################################################
        macbook = inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs user;
            hostName = "macbook";
          };
          modules = [
            ./hosts/macbook
            ./modules/common
            ./modules/graphical
            ./modules/laptop
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit user;
                hostName = "macbook";
                mainMonitor = "eDP-1";
              };
              home-manager.users.${user} = {
                imports = [
                  ./modules/laptop/home.nix
                ];
              };
            }
          ];
        };

      };
    };
}
