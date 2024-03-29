{ pkgs, ... }: {
  home = {
    stateVersion = "23.11";
    packages = [
      pkgs.kodi-loaded
      pkgs.retroarch-loaded
      pkgs.bitwig-studio
    ];
  };

  programs.fish.loginShellInit = ''
    exec systemd-cat --identifier=sway sway
  '';

  services.wlsunset.systemdTarget = "null.target";

  wayland.windowManager.sway = {
    config = {
      startup = [
        { command = "${pkgs.kodi-loaded}/bin/kodi"; }
        { command = "${pkgs.retroarch-loaded}/bin/retroarch"; }
      ];
      workspaceOutputAssign = [
        # Hopefully this works? Might be HDMI-A-1
        { output = "*"; workspace = "5"; }
      ];
    };
    sleep = {
      preferredType = "suspend";
      lockBefore = false;
      auto = {
        enable = true;
        idleMinutes = 30;
      };
    };
    wallpaper = pkgs.wallpaper.anime-girl-cat;
    extraConfig = ''
      for_window [app_id=org.libretro.RetroArch] fullscreen disable
      for_window [class=Kodi] fullscreen disable
    '';
  };
}
