{ pkgs, ... }: {
  config = {
    programs.sway.enable = true;
    programs.sway.extraPackages = with pkgs; [
      swaylock
      swayidle
      dmenu
      brightnessctl
      playerctl
      libinput
      xorg.xev
      gnome3.nautilus
      keepassxc
      font-manager
      gnome3.seahorse
      wl-clipboard
      wofi
      waybar
      gnome3.adwaita-icon-theme # for the two icons in the default wofi setup
      wlsunset
      # sway screenshots
      grim
      slurp
    ];
    # mkdir -p $HOME/.config/sway && ln -s /etc/sway-config $HOME/.config/sway/config
    environment.etc."sway-config".source = ./sway-config;
    # mkdir -p $HOME/.config/wofi && ln -s /etc/wofi-style.css $HOME/.config/wofi/style.css
    environment.etc."wofi-style.css".source = ./wofi-style.css;
    # Waybar checks /etc/xdg/waybar for configuration files so no need to create links
    environment.etc."xdg/waybar/style.css".source = ./waybar-style.css;
    environment.etc."xdg/waybar/config".source = ./waybar-config.json;
  };
}