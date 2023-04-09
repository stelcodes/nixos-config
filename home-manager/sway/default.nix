pkgs: config: {

  home.packages = [
    pkgs.swaylock
    pkgs.swayidle
    pkgs.brightnessctl
    pkgs.playerctl
    pkgs.libinput
    pkgs.wev
    pkgs.gnome3.nautilus
    pkgs.keepassxc
    pkgs.font-manager
    pkgs.gnome3.seahorse
    pkgs.wl-clipboard
    pkgs.wofi
    pkgs.gnome3.adwaita-icon-theme # for the two icons in the default wofi setup
    pkgs.wlsunset
    pkgs.grim
    pkgs.slurp
    pkgs.pamixer
    pkgs.wofi-emoji
  ];

  xdg.configFile = {
    "wofi/config".text = "allow_images=true";
    "wofi/style.css".source = ./wofi.css;
  };

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

    config = {
      assigns = {
        "1" = [{ class = "^Spotify$"; }];
        # "2" = [{ class = "^Firefox$"; }];
        # "3" = [{ title = "^Alacritty$"; }];
        "4" = [{ class = "^Gimp$"; } { title = "Shotcut$"; }];
        "5" = [{ class = "^Thunderbird$"; }];
        "6" = [{ title = "^calibre"; }];
      };
      terminal = "${pkgs.kitty}/bin/kitty";
      menu = "${pkgs.wofi}/bin/wofi --show run";
      modifier = "Mod4";
      fonts = {
        names = [ "NotoSansMono Nerd Font" ];
        size = 8.0;
      };
      bars = [ ];
      colors = {
        focused = {
          background = "#2e3440";
          border = "#616e88";
          childBorder = "#616e88";
          indicator = "#2e9ef4";
          text = "#eceff4";
        };
        unfocused = {
          background = "#222730";
          border = "#2e3440";
          childBorder = "#2e3440";
          indicator = "#2e9ef4";
          text = "#eceff4";
        };
      };
      window = {
        hideEdgeBorders = "both";
        border = 1;
      };
      keybindings =
        let modifier = config.wayland.windowManager.sway.config.modifier;
        in
        pkgs.lib.mkOptionDefault {
          "${modifier}+tab" = "workspace next";
          "${modifier}+shift+tab" = "workspace prev";
          # backtick ` is called grave
          "${modifier}+grave" = "exec wofi-emoji";
        };
      keycodebindings = {
        # Use xev to get keycodes, libinput gives wrong codes for some reason
        "232" = "exec brightnessctl set 5%-"; # f1
        "233" = "exec brightnessctl set +5%"; # f2
        "128" =
          "exec slurp | grim -g - ~/pictures/screenshots/grim:$(date -Iseconds).png"; # f3
        "212" = "layout stacked"; # f4
        "237" =
          "exec brightnessctl --device='smc::kbd_backlight' set 10%-"; # f5
        "238" =
          "exec brightnessctl --device='smc::kbd_backlight' set +10%"; # f6
        "173" = "exec playerctl previous"; # f7
        "172" = "exec playerctl play-pause"; # f8
        "171" = "exec playerctl next"; # f9
        "121" = "exec pamixer --toggle-mute"; # f10
        "122" = "exec pamixer --decrease 5"; # f11
        "123" = "exec pamixer --increase 5"; # f12
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
        # "*" = { bg = "/home/stel/pictures/wallpapers/pretty-nord.jpg fill"; };
        "*" = { bg = "#2e3440 solid_color"; };
      };
      startup = [
        { command = "protonmail-bridge"; }
        {
          command = "wlsunset -l 42 -L -83";
        }
        # This will lock your screen after 300 seconds of inactivity, then turn off
        # your displays after another 300 seconds, and turn your screens back on when
        # resumed. It will also lock your screen before your computer goes to sleep.
        # {
        #   command = ''
        #     swayidle -w \
        #     timeout 300 'swaylock -f -c 000000' \
        #     timeout 600 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' \
        #     before-sleep 'swaylock -f -c 000000'
        #   '';
        # }
        # {
        #   command = "sleep 7 && systemctl --user restart waybar";
        #   always = true;
        # }
      ];
    };
  };

  programs.waybar = {
    enable = true;
    style = builtins.readFile ./waybar.css;
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
        "idle_inhibitor"
        "clock"
      ];
      "sway/workspaces" = {
        disable-scroll = true;
        all-outputs = true;
        format = "{icon}";
        format-icons = {
          "1" = "vibes";
          "2" = "www";
          "3" = "term";
          "4" = "art";
          "5" = "mail";
          "6" = "books";
          default = "scratch";
        };
        persistent_workspaces = {
          "1" = [ ];
          "2" = [ ];
          "3" = [ ];
          "4" = [ ];
          "5" = [ ];
          "6" = [ ];
        };
      };
      cpu = {
        interval = 10;
        format = "{usage} ";
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
        format = "{ifname}";
        format-ethernet = "{ifname} ";
        format-disconnected = "";
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
        format-icons = [ " " " " " " " " " " ];
        max-length = 40;
      };
      idle_inhibitor = {
        format = "{icon}";
        format-icons = {
          activated = " ";
          deactivated = " ";
        };
      };
      backlight = {
        interval = 5;
        format = "{percent} {icon}";
        format-icons = [ "" "" "" ];
      };
    }];
  };
}