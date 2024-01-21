{ pkgs, inputs, ... }: {

  home = {
    stateVersion = "23.05";
    packages = [
      pkgs.obsidian
      pkgs.gimp-with-plugins
      pkgs.gajim
      pkgs.signal-desktop
      pkgs.fractal
      inputs.gpt4all-nix.packages.${pkgs.system}.default
      inputs.arcsearch.defaultPackage.${pkgs.system}
      pkgs.retroarch-loaded
      pkgs.kodi-loaded
      pkgs.discord-firefox
      pkgs.flac
    ];
  };
  wayland.windowManager.sway = {
    config.workspaceOutputAssign = [
      { output = "HDMI-A-1"; workspace = "5"; }
    ];
    lockBeforeSleep = true;
    idleSleep = {
      enable = true;
      sleepType = "suspend-then-hibernate";
    };
    wallpaper = pkgs.fetchurl {
      url = "https://i.imgur.com/NnXQqDZ.jpg";
      hash = "sha256-yth6v4M5UhXkxQ/bfd3iwFRi0FDGIjcqR37737D8P5w=";
    };
  };
}
