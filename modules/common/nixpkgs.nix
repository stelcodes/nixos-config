{ lib, inputs, pkgs, ... }: {
  config = {
    nix = {
      package = pkgs.nixVersions.latest;
      gc = {
        automatic = true;
        options = "--delete-older-than 30d";
      };
      settings = {
        # auto-optimise-store = true;
        experimental-features = [ "nix-command" "flakes" ];
        # For cross compilation, not sure if necessary
        # extra-platforms = config.boot.binfmt.emulatedSystems;
        flake-registry = "${inputs.flake-registry}/flake-registry.json";
      };
      extraOptions = ''
        warn-dirty = false
      '';
      registry.nixpkgs.flake = inputs.nixpkgs; # For flake commands
      nixPath = [ "nixpkgs=${inputs.nixpkgs}" ]; # For legacy commands
    };
    nixpkgs =
      let
        config = {
          permittedInsecurePackages = [ ];
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
            "facetimehd-firmware"
            "facetimehd-calibration"
            "libretro-snes9x"
            "vscode"
            "zsh-abbr"
          ];
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
  };
}
