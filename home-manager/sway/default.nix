pkgs: config: {

  home.packages = [
    pkgs.swaylock
    pkgs.swayidle
    pkgs.dmenu
    pkgs.brightnessctl
    pkgs.playerctl
    pkgs.libinput
    pkgs.xorg.xev
    pkgs.slurp # dependency for swaytools (installed via pip install --user swaytools)
    pkgs.gnome3.nautilus
    pkgs.keepassxc
    pkgs.font-manager
    pkgs.gnome3.seahorse
    pkgs.wl-clipboard
  ];

  wayland.windowManager.sway = {
    enable = true;
    config = {
      assigns = {
        "1:vibes" = [{ class = "^Spotify$"; }];
        "2:www" = [{ class = "^Firefox$"; }];
        "3:term" = [{ title = "^Alacritty$"; }];
        "4:art" = [ { class = "^Gimp$"; } { title = "Shotcut$"; } ];
        "5:mail" = [{ class = "^Thunderbird$"; }];
        "6:books" = [{ title = "^calibre"; }];
      };
      terminal = "alacritty";
      modifier = "Mod4";
      fonts = {
        names = [ "NotoMono Nerd Font" ];
        size = 8.0;
      };
      bars = [ ];
      colors = {
        focused = {
          background = "#2e3440";
          border = "#2e3440";
          childBorder = "#8c738c";
          indicator = "#2e9ef4";
          text = "#eceff4";
        };
      };
      window = { hideEdgeBorders = "smart"; };
      keybindings =
        let modifier = config.wayland.windowManager.sway.config.modifier;
        in pkgs.lib.mkOptionDefault {
          "${modifier}+tab" = "workspace next";
          "${modifier}+shift+tab" = "workspace prev";
        };
      keycodebindings = {
        # Use xev to get keycodes, libinput gives wrong codes for some reason
        "232" = "exec brightnessctl set 5%-"; # f1
        "233" = "exec brightnessctl set +5%"; # f2
        "128" = "layout tabbed"; # f3
        "212" = "layout stacked"; # f4
        "237" =
          "exec brightnessctl --device='smc::kbd_backlight' set 10%-"; # f5
        "238" =
          "exec brightnessctl --device='smc::kbd_backlight' set +10%"; # f6
        "173" = "exec playerctl previous"; # f7
        "172" = "exec playerctl play-pause"; # f8
        "171" = "exec playerctl next"; # f9
        "121" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle"; # f10
        "122" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%"; # f11
        "123" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%"; # f12
      };
      input = {
        "1452:657:Apple_Inc._Apple_Internal_Keyboard_/_Trackpad" = {
          xkb_layout = "us";
          xkb_variant = "mac";
          xkb_options = "caps:escape";
        };
        "type:touchpad" = {
          natural_scroll = "enabled";
          dwt = "enabled";
          tap = "enabled";
          tap_button_map = "lrm";
        };
      };
      output = {
        "*" = { bg = "~/Pictures/wallpapers/pretty-nord.jpg fill"; };
      };
      startup = [
        { command = "exec alacritty"; }
        { command = "exec firefox"; }
        { command = "exec gimp"; }
        { command = "exec spotifywm"; }
        { command = "exec protonmail-bridge"; }
        { command = "exec thunderbird"; }
        {
          command = "exec calibre";
        }
        # This will lock your screen after 300 seconds of inactivity, then turn off
        # your displays after another 300 seconds, and turn your screens back on when
        # resumed. It will also lock your screen before your computer goes to sleep.
        {
          command = ''
            exec swayidle -w \
            timeout 300 'swaylock -f -c 000000' \
            timeout 600 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' \
            before-sleep 'swaylock -f -c 000000'
          '';
        }
        {
          command = "sleep 7 && systemctl --user restart waybar";
          always = true;
        }
      ];
    };
  };

  programs.waybar = {
    enable = true;
    style = builtins.readFile /home/stel/config/misc/waybar.css;
    systemd.enable = true;
    settings = [{
      layer = "top";
      position = "bottom";
      height = 20;
      output = [ "eDP-1" ];
      modules-left = [ "sway/workspaces" "sway/mode" ];
      modules-center = [ ];
      modules-right = [
        "cpu"
        "memory"
        "disk"
        "network"
        "backlight"
        "pulseaudio"
        "battery"
        "clock"
      ];
      modules = {
        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          format = "{name}";
          persistent_workspaces = {
            "1:vibes" = [ ];
            "2:www" = [ ];
            "3:term" = [ ];
            "4:art" = [ ];
            "5:mail" = [ ];
          };
        };
        cpu = {
          interval = 10;
          format = "{} ";
        };
        memory = {
          interval = 30;
          format = "{} ";
        };
        disk = {
          interval = 30;
          format = "{percentage_used} ";
        };
        network = {
          # format = "{bandwidthDownBits}";
          max-length = 50;
          format-wifi = "{essid} {signalStrength} ";
        };
        pulseaudio = {
          format = "{volume} {icon}";
          format-bluetooth = "{volume} {icon} ";
          format-muted = "{volume} ";
          format-icons = { default = [ "" "" ]; };
          on-click = "pavucontrol";
        };
        clock = { format-alt = "{:%a, %d. %b  %H:%M}"; };
        battery = {
          format = "{capacity} {icon}";
          format-icons = [ "" "" "" "" "" ];
          max-length = 40;
        };
        backlight = {
          interval = 5;
          format = "{percent} {icon}";
          format-icons = [ "" "" ];
        };
      };
    }];
  };
}
