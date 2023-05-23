{
  description = "My Personal NixOS System Flake Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; # Nix Packages

    home-manager = {
      # User Package Management
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Function that tells my flake which to use and what do what to do with the dependencies.
  outputs = inputs @ { self, nixpkgs, home-manager, ... }:
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
        framework = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs user;
            hostName = "framework";
          };
          modules = [
            ./hosts/framework
            ./modules/common
            ./modules/laptop
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit user;
                hostName = "framework";
                mainMonitor = "eDP-1";
              };
              home-manager.users.${user} = {
                imports = [
                  ./home-manager
                  ./home-manager/gtk
                  ./home-manager/fish
                  ./home-manager/neovim
                  ./home-manager/sway
                ];
              };
            }
          ];
        };


        ########################################################################
        # macbook laptop i7-4650U
        ########################################################################
        macbook = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs user;
            hostName = "macbook";
          };
          modules = [
            ./hosts/macbook
            ./modules/common
            ./modules/laptop
            home-manager.nixosModules.home-manager
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
                  ./home-manager
                  ./home-manager/gtk
                  ./home-manager/fish
                  ./home-manager/neovim
                  ./home-manager/sway
                ];
              };
            }
          ];
        };

      };
    };
}
