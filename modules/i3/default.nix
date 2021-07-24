{ pkgs, ... }: {
  services.xserver.enable = true;
  services.xserver.autorun = true;
  services.xserver.libinput.enable = true;
  services.xserver.libinput.touchpad.naturalScrolling = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "caps:escape";
  services.xserver.xkbVariant = "mac";
  services.xserver.desktopManager.xterm.enable = false;
  # services.xserver.displayManager.session = [{
  #   manage = "window";
  #   name = "sway";
  #   start = "exec sway";
  # }];
  services.xserver.displayManager.session = [];
  services.xserver.displayManager.autoLogin.enable = false;
  services.xserver.displayManager.autoLogin.user = "stel";
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.lightdm.background = /home/stel/pictures/wallpapers/pretty-nord.jpg;
  services.xserver.displayManager.defaultSession = "none+i3";
  services.xserver.windowManager.i3.enable = true;
  services.xserver.windowManager.i3.configFile = ./i3-config;
  programs.zsh.shellAliases."xgui" = "doas systemctl start graphical.target";
  environment.systemPackages = [ pkgs.feh ];
  environment.etc."i3status.conf".source = ./i3status.conf;
}
