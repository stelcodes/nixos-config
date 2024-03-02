{ pkgs, inputs, ... }: {

  home = {
    stateVersion = "23.05";
    packages = [
      pkgs.obsidian
      pkgs.gimp-with-plugins
      pkgs.gajim
      pkgs.signal-desktop
      pkgs.fractal
      # inputs.gpt4all-nix.packages.${pkgs.system}.default
      pkgs.unstable.gpt4all-chat
      inputs.arcsearch.defaultPackage.${pkgs.system}
      pkgs.retroarch-loaded
      pkgs.kodi-loaded
      pkgs.flac
      pkgs.pdfcpu # Convert a pdf to booklet for printing!
      pkgs.smartmontools # Tools for monitoring the health of hard drives
      pkgs.gnome3.cheese # for testing webcams
      pkgs.amdgpu_top
      # pkgs.lact # amdgpu controller daemon + gui https://github.com/ilya-zlobintsev/LACT
      pkgs.blender
      pkgs.libreoffice
      pkgs.guitarix
      pkgs.gxplugins-lv2
      pkgs.bk
      pkgs.dconf2nix
      (pkgs.wrapOBS {
        plugins = with pkgs.obs-studio-plugins; [
          wlrobs
          obs-backgroundremoval
          obs-pipewire-audio-capture
          obs-vaapi # https://wiki.archlinux.org/title/Open_Broadcaster_Software#Encoding_using_GStreamer
        ];
      })
      pkgs.easyeffects
      pkgs.calibre
      pkgs.kdenlive
      pkgs.ffmpeg
      pkgs.discord-firefox
      pkgs.spotify-firefox
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
    wallpaper = pkgs.wallpaper.rei-moon;
  };
}
