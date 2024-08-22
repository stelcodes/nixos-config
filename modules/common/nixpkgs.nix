{ lib, inputs, ... }: {
  config = {
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
