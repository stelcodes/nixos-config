{ pkgs, ... }: {
  services.xserver.enable = true;
  services.xserver.autorun = false;
  services.xserver.libinput.enable = true;
  services.xserver.desktopManager.xterm.enable = false;
  services.xserver.displayManager.defaultSession = "none+i3";
  services.xserver.windowManager.i3.enable = true;
  services.xserver.windowManager.i3.configFile = ./i3-config;
  programs.zsh.shellAliases."xgui" = "doas systemctl start graphical.target";
  environment.systemPackages = [ pkgs.feh ];
}
