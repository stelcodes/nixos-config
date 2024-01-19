{ pkgs, ... }: {
  home = {
    stateVersion = "23.11";
    packages = [
      pkgs.kodi-loaded
      pkgs.retroarch-loaded
    ];
  };

  programs.fish.loginShellInit = ''
    exec systemd-cat --identifier=sway sway
  '';

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
    extraConfig = ''
      for_window [app_id=org.libretro.RetroArch] fullscreen enable
      for_window [class=Kodi] fullscreen enable
    '';
  };
}
