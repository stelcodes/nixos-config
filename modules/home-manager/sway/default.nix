{pkgs, ...}: {
  wayland.windowManager.sway = {
    enable = true;
    extraSessionCommands = ''
          export SDL_VIDEODRIVER=wayland
          # needs qt5.qtwayland in systemPackages
          export QT_QPA_PLATFORM=wayland
          export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
          # Fix for some Java AWT applications (e.g. Android Studio),
          # use this if they aren't displayed properly:
          export _JAVA_AWT_WM_NONREPARENTING=1
    '';
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      swaylock
      swayidle
      dmenu
      brightnessctl
      playerctl
      libinput
      xorg.xev
      gnome3.nautilus
      font-manager
      gnome3.seahorse
      wl-clipboard
      wofi
      # waybar
      gnome3.adwaita-icon-theme # for the two icons in the default wofi setup
      wlsunset
      # sway screenshots
      grim
      slurp
      rofimoji
      i3status
      alacritty
      pamixer # to control volume with pipewire
    ];
  };



}
