{ pkgs, ... }: {

  home.packages = [
    pkgs.swaylock
    pkgs.swayidle
    pkgs.brightnessctl
    pkgs.playerctl
    pkgs.libinput
    pkgs.wev
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
    pkgs.libnotify
    pkgs.pomo
    pkgs.foot
  ];

  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      # needs qt5.qtwayland in systemPackages
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      # Fix for some Java AWT applications (e.g. Android Studio),
      # use this if they aren't displayed properly:
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
      # Automatically add electron/chromium wayland flags
      export NIXOS_OZONE_WL=1
      # Fix for GTK scale issues when also using Cinnamon
      # export GDK_SCALE=1
      export GDK_DPI_SCALE=-1
    '';
    config = rec {
      terminal = "${pkgs.foot}/bin/foot sh -c 'tmux attach; fish'";
      menu = "${pkgs.wofi}/bin/wofi --show run --width 800 --height 400 --term foot";
      modifier = "Mod4";
      fonts = {
        names = [ "FiraMono Nerd Font" ];
        style = "Regular";
        size = 8.0;
      };
      bars = [ ];
      colors = {
        focused = {
          background = "#2e3440";
          border = "#616e88";
          childBorder = "#616e88";
          indicator = "#a3be8c";
          text = "#eceff4";
        };
        unfocused = {
          background = "#222730";
          border = "#2e3440";
          childBorder = "#2e3440";
          indicator = "#616e88";
          text = "#eceff4";
        };
        focusedInactive = {
          background = "#222730";
          border = "#2e3440";
          childBorder = "#2e3440";
          indicator = "#616e88";
          text = "#eceff4";
        };
      };
      window = {
        hideEdgeBorders = "none";
        border = 1;
      };
      workspaceLayout = "tabbed";
      keybindings =
        pkgs.lib.mkOptionDefault {
          "${modifier}+tab" = "workspace back_and_forth";
          # "${modifier}+shift+tab" = "workspace prev";
          # backtick ` is called grave
          "${modifier}+grave" = "exec wofi-emoji";
          "${modifier}+shift+r" = "reload";
          "${modifier}+c" = "exec rebuild";
          "${modifier}+space" = "exec ${menu}";
          "${modifier}+backspace" = "exec firefox";
          "${modifier}+o" = "output eDP-1 toggle";
          "${modifier}+n" = "exec makoctl dismiss --all";
          "${modifier}+shift+o" = "output eDP-1 dpms toggle";
          "${modifier}+p" = "exec doas protonvpn connect --fastest";
          "${modifier}+less" = "focus parent";
          "${modifier}+greater" = "focus child";
          "${modifier}+semicolon" = "exec ~/nixos-config/misc/sway-toggle-laptop-resolution.clj";
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
      modes = pkgs.lib.mkOptionDefault {
        resize = {
          "r" = "resize set width 80 ppt height 90 ppt, move position center";
        };
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
        "BOE 0x095F Unknown" = {
          scale = "1.5";
          position = "0 1080";
        };
        # Epson projector
        "Seiko Epson Corporation EPSON PJ 0x00000101" = {
          position = "0 0";
        };
      };
      startup = [
        # Stopped working when switching between Cinnamon and Sway (see waybar config)
        { command = "systemctl --user is-active waybar || systemctl --user restart waybar"; always = true; }
        # { command = "pgrep waybar || waybar"; always = true; }
      ];
    };
    extraConfig = ''
      bindgesture swipe:4:right workspace prev
      bindgesture swipe:4:left workspace next
      bindgesture swipe:3:right focus left
      bindgesture swipe:3:left focus right
      # I have to put this in extraConfig because it needs to be after the type:keyboard rule
      # and config.input only accepts unordered attribute set atm
      input "1:1:AT_Translated_Set_2_keyboard" xkb_options caps:escape,altwin:swap_alt_win
      bindswitch lid:off output * dpms off
      for_window [app_id=org.gnome.Calculator] floating enable
      for_window [class=REAPER] floating enable
      for_window [app_id=nmtui] floating enable
      for_window [app_id=qalculate-gtk] floating enable
      for_window [app_id=\.?blueman-manager(-wrapped)?] floating enable, resize set width 80 ppt height 80 ppt, move position center
      for_window [app_id=nixos_rebuild_log] floating enable, resize set width 80 ppt height 80 ppt, move position center
    '';
  };

  services = {
    swayidle = {
      enable = true;
      events = [
        {
          event = "before-sleep";
          command = "${pkgs.pomo}/bin/pomo stop; ${pkgs.swaylock}/bin/swaylock; ${pkgs.sway}/bin/swaymsg 'output * dpms off'";
        }
        {
          event = "after-resume";
          command = "${pkgs.pomo}/bin/pomo start; ${pkgs.sway}/bin/swaymsg 'output * dpms on'";
        }
      ];
      timeouts = [
        {
          timeout = 600;
          command = "${pkgs.systemd}/bin/systemctl suspend-then-hibernate";
        }
      ];
      systemdTarget = "sway-session.target";
    };

    wlsunset = {
      enable = true;
      latitude = "42";
      longitude = "-83";
      temperature = {
        day = 6500;
        night = 3000;
      };
      systemdTarget = "sway-session.target";
    };

    mako = {
      enable = true;
      anchor = "bottom-right";
      font = "FiraMono Nerd Font 10";
      extraConfig = ''
        sort=-time
        layer=overlay
        background-color=#2e3440
        width=300
        height=110
        border-size=2
        border-color=#88c0d0
        border-radius=5
        icons=1
        max-icon-size=64
        default-timeout=30000
        ignore-timeout=1
        padding=14
        margin=20

        [urgency=low]
        border-color=#81a1c1

        [urgency=normal]
        border-color=#88c0d0

        [urgency=high]
        border-color=#bf616a
        default-timeout=0
      '';
    };
  };

  programs.swaylock = {
    enable = true;
    settings = {
      color = "2e3440";
      font-size = 24;
      indicator-idle-visible = false;
      indicator-radius = 100;
      show-failed-attempts = true;
    };
  };

  programs.waybar = {
    enable = true;
    style = builtins.readFile ./waybar.css;
    # Stopped working when switching between Cinnamon and Sway
    # [error] Bar need to run under Wayland
    # GTK4 get_default_display was saying it was still X11
    systemd = {
      enable = true;
      target = "sway-session.target";
    };
    settings = [{
      layer = "top";
      position = "bottom";
      height = 20;
      output = [ "eDP-1" ];
      modules-left = [ "sway/workspaces" "sway/mode" ];
      modules-center = [ "clock" "custom/pomo" ];
      modules-right = [
        "custom/rebuild"
        "network#1"
        "network#2"
        "cpu"
        "backlight"
        "pulseaudio"
        "bluetooth"
        "battery"
        "idle_inhibitor"
      ];
      "custom/pomo" = {
        format = "{} 󱎫 ";
        exec = "${pkgs.pomo}/bin/pomo clock";
        interval = 1;
        on-click = "${pkgs.pomo}/bin/pomo pause";
        on-click-right = "${pkgs.pomo}/bin/pomo stop";
      };
      "custom/rebuild" = {
        format = "rebuild: {}";
        max-length = 25;
        interval = 2;
        exec-if = "test -f /tmp/nixos-rebuild.status";
        exec = "echo \"$(< /tmp/nixos-rebuild.status)\"";
        # Waybar env does not include my normal PATH so I'm using fish as a wrapper
        on-click = "${pkgs.foot}/bin/foot --app-id=nixos_rebuild_log ${pkgs.coreutils}/bin/tail -n +1 -F /tmp/nixos-rebuild.log";
      };
      "sway/workspaces" = {
        disable-scroll = true;
        all-outputs = true;
        format = "{icon}";
        format-icons = {
          "1" = "term";
          "2" = "www";
          "3" = "notes";
          "4" = "social";
          "5" = "music";
          "6" = "sys";
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
      bluetooth = {
        format = "";
        on-click = "${pkgs.blueman}/bin/blueman-manager";
      };
      "network#1" = {
        max-length = 60;
        interface = "wl*";
        # format = "{ifname}";
        # format-ethernet = "{ifname} ";
        format-disconnected = "";
        format-wifi = "{essid} {signalStrength} ";
        on-click = "${pkgs.foot}/bin/foot --app-id=nmtui ${pkgs.networkmanager}/bin/nmtui";
      };
      "network#2" = {
        max-length = 60;
        interface = "proton*";
        format = "";
        format-disconnected = "";
        on-click = "${pkgs.foot}/bin/foot --app-id=nmtui ${pkgs.networkmanager}/bin/nmtui";
      };
      pulseaudio = {
        format = "{volume} {icon}";
        format-bluetooth = "{volume} {icon} ";
        format-muted = "{volume} ";
        format-icons = { default = [ "" "" ]; };
        on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
      };
      clock = {
        format = "{:%a %b %d %I:%M %p} 󱛡";
        format-alt = "{:week %U day %j} 󱛡";
        tooltip-format = "<tt><small>{calendar}</small></tt>";
      };
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
