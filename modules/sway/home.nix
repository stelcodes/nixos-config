{ pkgs, theme, ... }:
let
  viewRebuildLogCmd = "${pkgs.foot}/bin/foot --app-id=nixos_rebuild_log ${pkgs.coreutils}/bin/tail -n +1 -F -s 0.2 $HOME/tmp/rebuild/latest";
  modifier = "Mod4";
in
{

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
    pkgs.wdisplays
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
      # Forgot what graphical program is being run from systemd user service
      # Could use systemd.user.extraConfig = '''DefaultEnvironment="GDK_DPI_SCALE=-1"'''
      ${pkgs.systemd}/bin/systemctl --user import-environment GDK_DPI_SCALE
    '';
    config = {
      terminal = "${pkgs.foot}/bin/foot sh -c 'tmux attach; fish'";
      menu = "${pkgs.wofi}/bin/wofi --show run --width 800 --height 400 --term foot";
      modifier = modifier;
      fonts = {
        names = [ "FiraMono Nerd Font" ];
        style = "Regular";
        size = 8.0;
      };
      bars = [ ];
      colors = {
        focused = {
          background = theme.bg;
          border = theme.bg3;
          childBorder = theme.bg3;
          indicator = theme.green;
          text = theme.fg;
        };
        unfocused = {
          background = theme.black;
          border = theme.bg;
          childBorder = theme.bg;
          indicator = theme.bg3;
          text = theme.fg;
        };
        focusedInactive = {
          background = theme.black;
          border = theme.bg;
          childBorder = theme.bg;
          indicator = theme.bg3;
          text = theme.fg;
        };
      };
      window = {
        hideEdgeBorders = "smart";
        border = 1;
      };
      workspaceLayout = "tabbed";
      keybindings =
        pkgs.lib.mkOptionDefault {
          # Use "Shift" to properly override defaults
          "${modifier}+tab" = "focus next";
          "${modifier}+Shift+tab" = "focus prev";
          "${modifier}+grave" = "exec wofi-emoji";
          "${modifier}+Shift+r" = "reload; exec ${pkgs.systemd}/bin/systemctl --user restart waybar";
          "${modifier}+r" = "mode resize";
          "${modifier}+c" = "exec ${pkgs.toggle-sway-window}/bin/toggle-sway-window --id nixos_rebuild_log -- ${viewRebuildLogCmd}";
          "${modifier}+Shift+c" = "exec rebuild";
          "${modifier}+backspace" = "exec firefox";
          "${modifier}+Shift+backspace" = "exec firefox --private-window";
          "${modifier}+n" = "exec makoctl dismiss --all";
          "${modifier}+i" = "exec doas protonvpn connect --fastest";
          "${modifier}+p" = "exec ${pkgs.cycle-pulse-sink}/bin/cycle-pulse-sink";
          "${modifier}+less" = "focus parent";
          "${modifier}+greater" = "focus child";
          "${modifier}+semicolon" = "layout toggle split tabbed stacking";
          "${modifier}+apostrophe" = "split toggle";
          "${modifier}+backslash" = "exec ${pkgs.cycle-sway-scale}/bin/cycle-sway-scale";
          "${modifier}+bar" = "exec ${pkgs.toggle-service}/bin/toggle-service wlsunset";
          "${modifier}+v" = "exec ${pkgs.toggle-sway-window}/bin/toggle-sway-window --id org.keepassxc.KeePassXC -- ${pkgs.keepassxc}/bin/keepassxc";
          "${modifier}+delete" = "exec ${pkgs.swaylock}/bin/swaylock";
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
      modes = pkgs.lib.mkOptionDefault {
        resize = {
          "r" = "resize set width 80 ppt height 90 ppt, move position center";
        };
      };
      # There's a big problem with how home-manager handles the input and output values
      # The ordering *does* matter so the value should be a list, not a set.
      input = {
        "type:keyboard" = {
          xkb_options = "caps:escape,altwin:swap_alt_win";
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
        "*" = { bg = "${theme.bg} solid_color"; };
        # Framework screen
        "BOE 0x095F Unknown" = {
          scale = "1.5";
          position = "0 0";
        };
        # Epson projector
        "Seiko Epson Corporation EPSON PJ 0x00000101" = {
          position = "0 0";
        };
      };
      startup = [
        # Import sway-related environment variables into systemd user services
        { command = "${pkgs.systemd}/bin/systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP SWAYSOCK I3SOCK DISPLAY"; }
        # Restart tmux so all shell environments contain sway-related environment variables
        { command = "${pkgs.systemd}/bin/systemctl --user restart tmux.service"; }
        { command = "${pkgs.systemd}/bin/systemctl --user is-active waybar || ${pkgs.systemd}/bin/systemctl --user restart waybar"; always = true; }
      ];
    };
    extraConfig = ''
      # Any future keyboard xkb_options overrides need to go here
      bindgesture swipe:4:right workspace prev
      bindgesture swipe:4:left workspace next
      bindgesture swipe:3:right focus left
      bindgesture swipe:3:left focus right
      bindswitch lid:off output * power off
      # Middle-click on a window title bar kills it
      bindsym button2 kill
      bindsym --locked ${modifier}+o output eDP-1 toggle
      bindsym --locked ${modifier}+Shift+o output eDP-1 power toggle
      bindsym --locked ${modifier}+Shift+delete exec ${pkgs.systemd}/bin/systemctl suspend-then-hibernate
      for_window [app_id=org.gnome.Calculator] floating enable
      for_window [class=REAPER] floating enable
      for_window [app_id=nmtui] floating enable
      for_window [app_id=qalculate-gtk] floating enable
      for_window [app_id=\.?blueman-manager(-wrapped)?] floating enable, resize set width 80 ppt height 80 ppt, move position center
      for_window [app_id=nixos_rebuild_log] floating enable, resize set width 80 ppt height 80 ppt, move position center
      for_window [app_id=htop] floating enable, resize set width 80 ppt height 80 ppt, move position center
      for_window [app_id=pavucontrol] floating enable, resize set width 80 ppt height 80 ppt, move position center
      for_window [app_id=org.keepassxc.KeePassXC] floating enable, resize set width 80 ppt height 80 ppt, move position center
      for_window [app_id=org.rncbc.qpwgraph] floating enable
      for_window [app_id="org.qbit.*" title="^\[[Bb]itsearch.*"] floating disable
      # Workaround for Bitwig moving itself to current workspace when scale changes
      for_window [class=com.bitwig.BitwigStudio] move container to workspace 5
    '';
    swaynag = {
      enable = true;
      settings = {
        warning = rec {
          background = theme.bgx;
          button-background = theme.bg1x;
          details-background = theme.bg1x;
          text = theme.fgx;
          button-text = theme.fgx;
          border = theme.bg2x;
          border-bottom = theme.bg3x;
          border-bottom-size = 3;
          button-border-size = 1;
        };
        error = rec {
          background = theme.bgx;
          button-background = theme.bg1x;
          details-background = theme.bg1x;
          text = theme.fgx;
          button-text = theme.fgx;
          border = theme.bg2x;
          border-bottom = theme.redx;
          border-bottom-size = 3;
          button-border-size = 1;
        };
      };
    };
  };

  services = {
    swayidle = {
      enable = true;
      # Waits for commands to finish (-w) by default
      events = [
        {
          event = "before-sleep";
          command = "${pkgs.tmux-snapshot}/bin/tmux-snapshot; ${pkgs.swaylock}/bin/swaylock --daemonize; ${pkgs.sway}/bin/swaymsg 'output * power off'";
        }
        {
          event = "after-resume";
          command = "test -f $HOME/.local/share/pomo && ${pkgs.pomo}/bin/pomo start; ${pkgs.sway}/bin/swaymsg 'output * power on'";
        }
      ];
      timeouts = [
        {
          timeout = 900;
          command = let app = pkgs.writeShellApplication {
            name = "swayidle-timeout";
            runtimeInputs = [ pkgs.systemd pkgs.playerctl pkgs.gnugrep pkgs.acpi ];
            text = ''
              if playerctl status | grep -q "Playing" || acpi --ac-adapter | grep -q "on-line"; then
                echo "Restarting..."
                systemctl --restart swayidle.service
              else
                echo "Suspending..."
                systemctl suspend-then-hibernate
              fi
            '';
          }; in "${app}/bin/swayidle-timeout";
        }
      ];
      systemdTarget = "sway-session.target";
    };

    wlsunset = {
      enable = true;
      # Using a bogus target name so wlsunset will not start automatically
      systemdTarget = "null.target";
      latitude = "38";
      longitude = "-124";
      temperature = {
        day = 6500;
        night = 4000;
      };
    };

    mako = {
      enable = true;
      anchor = "bottom-right";
      font = "FiraMono Nerd Font 10";
      extraConfig = ''
        sort=-time
        layer=overlay
        width=300
        height=110
        border-radius=5
        icons=1
        max-icon-size=64
        default-timeout=30000
        ignore-timeout=1
        padding=14
        margin=20
        background-color=${theme.bg}

        [urgency=low]
        border-color=${theme.blue}

        [urgency=normal]
        border-color=${theme.cyan}

        [urgency=high]
        border-color=${theme.red}
      '';
    };
  };

  programs.swaylock = {
    enable = true;
    settings = {
      color = theme.bgx;
      font-size = 24;
      indicator-idle-visible = false;
      indicator-radius = 100;
      show-failed-attempts = true;
    };
  };

  programs.waybar = {
    enable = true;
    style = ''
      @define-color bg ${theme.bg};
      @define-color bgOne ${theme.bg1};
      @define-color bgTwo ${theme.bg2};
      @define-color bgThree ${theme.bg3};
      @define-color red ${theme.red};
      ${builtins.readFile ./waybar.css}
    '';
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
      modules-left = [ "sway/workspaces" "sway/mode" "tray" ];
      modules-center = [ "clock" "custom/pomo" "custom/swayidle" ];
      modules-right = [
        "custom/rebuild"
        "network#1"
        "network#2"
        "cpu"
        "backlight"
        "wireplumber"
        "bluetooth"
        "battery"
      ];
      "custom/pomo" = {
        format = "{} 󱎫";
        exec = "${pkgs.pomo}/bin/pomo clock";
        interval = 1;
        on-click = "${pkgs.pomo}/bin/pomo pause";
        on-click-right = "${pkgs.pomo}/bin/pomo stop";
      };
      "custom/rebuild" = {
        format = "rebuild: {}";
        max-length = 25;
        interval = 2;
        exec-if = "test -f $HOME/tmp/rebuild/status";
        exec = "echo \"$(< $HOME/tmp/rebuild/status)\"";
        on-click = viewRebuildLogCmd;
      };
      "custom/swayidle" = {
        format = "{}";
        max-length = 2;
        interval = 2;
        # 󱥑 󱥐 octahedron
        # 󰦞 󰦝 shield
        # 󱓣 󰜗 snowflake
        exec = "if ${pkgs.systemd}/bin/systemctl --user is-active swayidle.service >/dev/null; then echo '󰜗'; else echo '󱓣'; fi";
        on-click = "${pkgs.toggle-service}/bin/toggle-service swayidle";
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
        on-click = "${pkgs.foot}/bin/foot --app-id=htop ${pkgs.htop}/bin/htop --tree --sort-key=PERCENT_CPU";
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
        format-on = "󰂲";
        on-click = "${pkgs.blueman}/bin/blueman-manager";
      };
      "network#1" = {
        max-length = 60;
        interface = "wl*";
        # format = "{ifname}";
        # format-ethernet = "{ifname} ";
        format-disconnected = "";
        format-wifi = "{essid} ";
        tooltip-format = "freq: {frequency} strength: {signalStrength}";
        on-click = "${pkgs.foot}/bin/foot --app-id=nmtui ${pkgs.networkmanager}/bin/nmtui";
      };
      "network#2" = {
        max-length = 60;
        interface = "proton*";
        format = "";
        format-disconnected = "";
        on-click = "${pkgs.foot}/bin/foot --app-id=nmtui ${pkgs.networkmanager}/bin/nmtui";
      };
      wireplumber = {
        format = "{node_name} {volume} {icon}";
        format-muted = "{volume} ";
        format-icons = { default = [ "" "" ]; };
        on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
        on-click-right = "${pkgs.cycle-pulse-sink}/bin/cycle-pulse-sink";
        on-click-middle = "${pkgs.helvum}/bin/helvum";
        max-volume = 100;
        scroll-step = 5;
      };
      clock = {
        format = "{:%a %b %d %I:%M %p} 󱛡";
        format-alt = "{:week %U day %j} 󱛡";
        tooltip-format = "<tt><small>{calendar}</small></tt>";
      };
      battery = {
        format = "{capacity} {icon}";
        format-charging = "{capacity} ";
        format-icons = [ "" "" "" "" "" ];
        max-length = 40;
      };
      idle_inhibitor = {
        format = "{icon}";
        format-icons = {
          activated = "";
          deactivated = "";
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
