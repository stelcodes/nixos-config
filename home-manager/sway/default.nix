pkgs: {

  home.packages = [
    pkgs.swaylock
    pkgs.swayidle
    pkgs.brightnessctl
    pkgs.playerctl
    pkgs.libinput
    pkgs.wev
    pkgs.gnome.nautilus
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
    config = rec {
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
          indicator = "#ebcb8b";
          text = "#eceff4";
        };
        unfocused = {
          background = "#222730";
          border = "#2e3440";
          childBorder = "#2e3440";
          indicator = "#ebcb8b";
          text = "#eceff4";
        };
        focusedInactive = {
          background = "#222730";
          border = "#2e3440";
          childBorder = "#2e3440";
          indicator = "#ebcb8b";
          text = "#eceff4";
        };
      };
      window = {
        hideEdgeBorders = "none";
        border = 1;
      };
      keybindings =
        pkgs.lib.mkOptionDefault {
          "${modifier}+tab" = "workspace next";
          "${modifier}+shift+tab" = "workspace prev";
          # backtick ` is called grave
          "${modifier}+grave" = "exec wofi-emoji";
          "${modifier}+shift+r" = "exec rebuild";
          "${modifier}+space" = "exec ${menu}";
          "${modifier}+backspace" = "exec firefox";
          "${modifier}+o" = "output eDP-1 toggle";
          "${modifier}+shift+o" = "output eDP-1 dpms toggle";
          "${modifier}+p" = "exec doas protonvpn connect --fastest";
          XF86MonBrightnessDown = "exec brightnessctl set 5%-";
          XF86MonBrightnessUp = "exec brightnessctl set +5%";
          XF86AudioPrev = "exec playerctl previous";
          XF86AudioPlay = "exec playerctl play-pause";
          XF86AudioNext = "exec playerctl next";
          XF86AudioMute = "exec pamixer --toggle-mute";
          XF86AudioLowerVolume = "exec pamixer --decrease 5";
          XF86AudioRaiseVolume = "exec pamixer --increase 5";
          Print = ''
            exec mkdir -p $XDG_PICTURES_DIR/screenshots && \
            slurp | grim -g - $XDG_PICTURES_DIR/screenshots/grim:$(date -u +%Y-%m-%dT%H:%M:%SZ).png
          '';
        };
      keycodebindings = {
        # Use xev to get keycodes, libinput gives wrong codes for some reason
        "212" = "exec rebuild"; # f4
        "237" = "exec brightnessctl --device='smc::kbd_backlight' set 10%-"; # f5
        "238" = "exec brightnessctl --device='smc::kbd_backlight' set +10%"; # f6
      };
      # There's a big problem with how home-manager handles the input and output values
      # The ordering *does* matter so the value should be a list, not a set.
      input = {
        "type:keyboard" = {
          xkb_options = "caps:escape";
          xkb_layout = "us";
        };
        "1452:657:Apple_Inc._Apple_Internal_Keyboard_/_Trackpad" = {
          xkb_variant = "mac";
        };
        "type:touchpad" = {
          natural_scroll = "enabled";
          dwt = "enabled";
          tap = "enabled";
          tap_button_map = "lrm";
        };
      };
      output = {
        "*" = { bg = "#2e3440 solid_color"; };
        # Framework screen
        "BOE 0x095F Unknown" = { scale = "1.5"; };
      };
      startup = [
        # Most of these should ideally be systemd user services
        { command = "wlsunset -l 42 -L -83"; }
        { command = "doas protonvpn connect --fastest"; }
        {
          command = "sleep 2 && systemctl --user is-active waybar || systemctl --user restart waybar";
          always = true;
        }
      ];
    };
    extraConfig = ''
      bindgesture swipe:3:right workspace prev
      bindgesture swipe:3:left workspace next
      # I have to put this in extraConfig because it needs to be after the type:keyboard rule
      # and config.input only accepts unordered attribute set atm
      input "1:1:AT_Translated_Set_2_keyboard" xkb_options caps:escape,altwin:swap_alt_win
      bindswitch lid:off output * dpms off
    '';
  };

  services = {
    swayidle = {
      enable = true;
      events = [
        {
          event = "before-sleep";
          command = "${pkgs.swaylock}/bin/swaylock -f -c 000000 && ${pkgs.sway}/bin/swaymsg 'output * dpms off'";
        }
        {
          event = "after-resume";
          command = "${pkgs.sway}/bin/swaymsg 'output * dpms on'";
        }
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
        "custom/rebuild"
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
      "custom/rebuild" = {
        format = "rebuild: {}";
        max-length = 25;
        interval = 2;
        exec-if = pkgs.writeShellScript "waybar-rebuild-exec-if" ''
          test -f /tmp/nixos-rebuild-status
        '';
        exec = pkgs.writeShellScript "waybar-rebuild-exec" ''
          echo "$(< /tmp/nixos-rebuild-status)"
        '';
        # Waybar env does not include my normal PATH so I'm using fish as a wrapper
        on-click = "${pkgs.fish}/bin/fish -c view-rebuild-log";
      };
      "sway/workspaces" = {
        disable-scroll = true;
        all-outputs = true;
        format = "{icon}";
        format-icons = {
          "1" = "term";
          "2" = "www";
          "3" = "sys";
          "4" = "notes";
          "5" = "vibes";
        };
        persistent_workspaces = {
          "1" = [ ];
          "2" = [ ];
          "3" = [ ];
          "4" = [ ];
          "5" = [ ];
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
        max-length = 60;
        format = "{ifname}";
        format-ethernet = "{ifname} ";
        format-disconnected = "";
        format-wifi = "{essid} {signalStrength} ";
        on-click = "${pkgs.kitty}/bin/kitty nmtui";
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
        format-icons = [ "" "" "" ];
      };
    }];
  };
}
