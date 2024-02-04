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
      pkgs.pdfcpu # Convert a pdf to booklet for printing!
      pkgs.smartmontools # Tools for monitoring the health of hard drives
      pkgs.gnome3.cheese # for testing webcams
      pkgs.amdgpu_top
      # pkgs.lact # amdgpu controller daemon + gui https://github.com/ilya-zlobintsev/LACT
      pkgs.blender
      pkgs.libreoffice
      pkgs.guitarix
      pkgs.bk
      pkgs.foliate # Sepia, single column
      pkgs.dconf2nix
    ];
  };
  wayland.windowManager.sway = {
    config.workspaceOutputAssign = [
      { output = "HDMI-A-1"; workspace = "5"; }
    ];
    mainDisplay = "DP-1";
    sleep = {
      preferredType = "hybrid-sleep";
      lockBefore = false;
      auto = {
        enable = true;
        idleMinutes = 15;
      };
    };
    wallpaper = pkgs.fetchurl {
      url = "https://i.imgur.com/NnXQqDZ.jpg";
      hash = "sha256-yth6v4M5UhXkxQ/bfd3iwFRi0FDGIjcqR37737D8P5w=";
    };
  };
}
