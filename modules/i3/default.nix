{ pkgs, ... }: {
  services.xserver.enable = true;
  services.xserver.libinput.enable = true;
  services.xserver.libinput.touchpad.naturalScrolling = true;
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "caps:escape";
  services.xserver.xkbVariant = "mac";
  services.xserver.desktopManager.xterm.enable = false;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.lightdm.background =
    /home/stel/pictures/wallpapers/pretty-nord.jpg;
  services.xserver.displayManager.defaultSession = "none+i3";
  services.xserver.windowManager.i3.enable = true;
  services.xserver.windowManager.i3.configFile = ./i3-config;
  environment.systemPackages =
    [ pkgs.feh pkgs.xidlehook pkgs.xss-lock pkgs.escrotum pkgs.rofimoji ];
  environment.etc."i3status.conf".source = ./i3status.conf;
}
