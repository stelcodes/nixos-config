{ pkgs, lib, config, adminName, hostName, ... }:
let
  viewRebuildLogCmd = "${pkgs.foot}/bin/foot --app-id=nixos_rebuild_log ${pkgs.coreutils}/bin/tail -n +1 -F -s 0.2 $HOME/tmp/rebuild/latest";
  modifier = "Mod4";
  # Sway does not support input or output identifier pattern matching so in order to apply settings for every
  # Apple keyboard, I have to create a new rule for each Apple keyboard I use.
  appleKeyboardIdentifiers = [
    "1452:657:Apple_Inc._Apple_Internal_Keyboard_/_Trackpad"
  ];
  appleKeyboardConfig = lib.strings.concatMapStrings
    (id: ''
      input "${id}" {
        xkb_layout us
        xkb_options caps:escape_shifted_capslock
        xkb_variant mac
      }
    '')
    appleKeyboardIdentifiers;
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
    pkgs.wl-clipboard
    pkgs.wofi
    pkgs.gnome3.adwaita-icon-theme # for the two icons in the default wofi setup
    pkgs.wlsunset
    pkgs.grim
    pkgs.slurp
    pkgs.pamixer
    pkgs.wofi-emoji
    pkgs.wtype
    pkgs.libnotify
    pkgs.pomo
    pkgs.wdisplays
    pkgs.foot
    pkgs.swappy
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
      terminal = "${pkgs.foot}/bin/foot sh -c 'tmux attach || tmux new-session -s config -c \"$HOME/nixos-config\"; fish'";
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
          background = config.theme.set.bg;
          border = config.theme.set.bg3;
          childBorder = config.theme.set.bg3;
          indicator = config.theme.set.green;
          text = config.theme.set.fg;
        };
        unfocused = {
          background = config.theme.set.black;
          border = config.theme.set.bg;
          childBorder = config.theme.set.bg;
          indicator = config.theme.set.bg3;
          text = config.theme.set.fg;
        };
        focusedInactive = {
          background = config.theme.set.black;
          border = config.theme.set.bg;
          childBorder = config.theme.set.bg;
          indicator = config.theme.set.bg3;
          text = config.theme.set.fg;
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
          "${modifier}+Shift+h" = "workspace prev";
          "${modifier}+Shift+l" = "workspace next";
          "${modifier}+Left" = "move left";
          "${modifier}+Right" = "move right";
          "${modifier}+Up" = "move up";
          "${modifier}+Down" = "move down";
          "${modifier}+Shift+Left" = "focus output left";
          "${modifier}+Shift+Right" = "focus output right";
          "${modifier}+Shift+Up" = "focus output up";
          "${modifier}+Shift+Down" = "focus output down";
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
          "${modifier}+p" = "exec ${pkgs.cycle-pulse-sink}/bin/cycle-pulse-sink";
          "${modifier}+less" = "focus parent";
          "${modifier}+greater" = "focus child";
          "${modifier}+semicolon" = "layout toggle split tabbed stacking";
          "${modifier}+apostrophe" = "split toggle";
          "${modifier}+backslash" = "exec ${pkgs.cycle-sway-scale}/bin/cycle-sway-scale";
          "${modifier}+bar" = "exec ${pkgs.toggle-service}/bin/toggle-service wlsunset";
          "${modifier}+v" = "exec ${pkgs.toggle-sway-window}/bin/toggle-sway-window --id org.keepassxc.KeePassXC -- ${pkgs.keepassxc}/bin/keepassxc";
          "${modifier}+delete" = "exec ${pkgs.swaylock}/bin/swaylock";
          "${modifier}+b" = "exec ${pkgs.toggle-sway-window}/bin/toggle-sway-window --id .blueman-manager-wrapped -- ${pkgs.blueman}/bin/blueman-manager";
          "${modifier}+m" = "exec ${pkgs.toggle-sway-window}/bin/toggle-sway-window --id system_monitor -- ${pkgs.foot}/bin/foot --app-id=system_monitor ${pkgs.btop}/bin/btop";
          XF86MonBrightnessDown = "exec brightnessctl set 5%-";
          XF86MonBrightnessUp = "exec brightnessctl set +5%";
          XF86AudioPrev = "exec playerctl previous";
          XF86AudioPlay = "exec playerctl play-pause";
          XF86AudioNext = "exec playerctl next";
          XF86AudioMute = "exec pamixer --toggle-mute";
          XF86AudioLowerVolume = "exec pamixer --decrease 5";
          XF86AudioRaiseVolume = "exec pamixer --increase 5";
          "${modifier}+Print" = let app = pkgs.writeShellApplication {
            name = "sway-screenshot-selection";
            runtimeInputs = [ pkgs.coreutils-full pkgs.slurp pkgs.grim pkgs.swappy ];
            text = ''
              mkdir -p "$XDG_PICTURES_DIR/screenshots"
              grim -g "$(slurp)" - | swappy -f -
            '';
          }; in "exec ${app}/bin/sway-screenshot-selection";
          Print = let app = pkgs.writeShellApplication {
            name = "sway-screenshot";
            runtimeInputs = [ pkgs.coreutils-full pkgs.sway pkgs.jq pkgs.grim pkgs.swappy ];
            text = ''
              mkdir -p "$XDG_PICTURES_DIR/screenshots"
              current_output=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name')
              grim -o "$current_output" - | swappy -f -
            '';
          }; in "exec ${app}/bin/sway-screenshot";
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
          # man xkeyboard-config
          xkb_options = "caps:escape_shifted_capslock,altwin:swap_alt_win";
          xkb_layout = "us";
        };
        "type:touchpad" = {
          natural_scroll = "enabled";
          dwt = "enabled";
          tap = "enabled";
          tap_button_map = "lrm";
        };
      };
      output = {
        "*" = { background = "${config.theme.set.wallpaper} fill ${config.theme.set.bg}"; };
        # Framework screen
        "BOE 0x095F Unknown" = {
          scale = "1.6";
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
        # Kill tmux so all shell environments contain sway-related environment variables
        { command = "${pkgs.tmux}/bin/tmux kill-server"; }
        { command = "${pkgs.systemd}/bin/systemctl is-active syncthing.service && ${pkgs.systemd}/bin/systemctl --user start syncthing-tray.service"; always = true; }
        { command = "${pkgs.systemd}/bin/systemctl --user is-active waybar || ${pkgs.systemd}/bin/systemctl --user restart waybar"; always = true; }
        { command = "${pkgs.systemd}/bin/systemctl --user start pomo-notify.service"; }
        { command = "${pkgs.obsidian}/bin/obsidian"; }
      ];
    };
    extraConfig = ''
      ${appleKeyboardConfig}
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
      for_window [app_id=system_monitor] floating enable, resize set width 80 ppt height 80 ppt, move position center
      for_window [app_id=pavucontrol] floating enable, resize set width 80 ppt height 80 ppt, move position center
      for_window [app_id=org.keepassxc.KeePassXC] floating enable, resize set width 80 ppt height 80 ppt, move position center
      for_window [app_id=org.rncbc.qpwgraph] floating enable
      for_window [app_id="org.qbit.*" title="^\[[Bb]itsearch.*"] floating disable
      # Workaround for Bitwig moving itself to current workspace when scale changes
      for_window [class=com.bitwig.BitwigStudio] move container to workspace 5
      for_window [app_id=obsidian] move container to workspace 3
    '';
    swaynag = {
      enable = true;
      settings = {
        warning = rec {
          background = config.theme.set.bgx;
          button-background = config.theme.set.bg1x;
          details-background = config.theme.set.bg1x;
          text = config.theme.set.fgx;
          button-text = config.theme.set.fgx;
          border = config.theme.set.bg2x;
          border-bottom = config.theme.set.bg3x;
          border-bottom-size = 3;
          button-border-size = 1;
        };
        error = rec {
          background = config.theme.set.bgx;
          button-background = config.theme.set.bg1x;
          details-background = config.theme.set.bg1x;
          text = config.theme.set.fgx;
          button-text = config.theme.set.fgx;
          border = config.theme.set.bg2x;
          border-bottom = config.theme.set.redx;
          border-bottom-size = 3;
          button-border-size = 1;
        };
      };
    };
  };

  systemd.user.services = {
    swayidle.Service.ExecStop = let app = pkgs.writeShellApplication {
      name = "swayidle-cleanup";
      runtimeInputs = [ pkgs.coreutils ];
      text = ''
        BLOCKFILE="$HOME/.local/share/idle-sleep-block"
        if test -f "$BLOCKFILE"; then
          rm "$BLOCKFILE"
        fi
      '';
    }; in "${app}/bin/swayidle-cleanup";

    polkit-gnome = {
      Unit = {
        Description = "GNOME polkit authentication agent";
      };
      Service = {
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "always";
      };
      Install = {
        WantedBy = [ "sway-session.target" ];
      };
    };

    syncthing-tray = {
      Unit = {
        Description = "Simple tray for syncthing file sync service";
      };
      Service = {
        ExecStart = "${pkgs.syncthing-tray}/bin/syncthing-tray -api 'st:${adminName}@${hostName}'";
        Restart = "always";
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
              if test -f "$HOME/.local/share/idle-sleep-block"; then
                echo "Restarting service because of user's idle-sleep-block file"
                systemctl --restart swayidle.service
              elif playerctl status | grep -q "Playing" || acpi --ac-adapter | grep -q "on-line"; then
                echo "Restarting service because "
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
      systemdTarget = "sway-session.target";
      latitude = "38";
      longitude = "-124";
      temperature = {
        day = 6500;
        night = 3500;
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
        background-color=${config.theme.set.bg}

        [urgency=low]
        border-color=${config.theme.set.blue}

        [urgency=normal]
        border-color=${config.theme.set.bg3}

        [urgency=high]
        border-color=${config.theme.set.red}
      '';
    };
  };

  programs.swaylock = {
    enable = true;
    settings = {
      color = config.theme.set.bgx;
      image = config.theme.set.wallpaper;
      font-size = 24;
      indicator-idle-visible = false;
      indicator-radius = 100;
      show-failed-attempts = true;
    };
  };

  programs.waybar = {
    enable = true;
    style = ''
      @define-color bg ${config.theme.set.bg};
      @define-color bgOne ${config.theme.set.bg1};
      @define-color bgTwo ${config.theme.set.bg2};
      @define-color bgThree ${config.theme.set.bg3};
      @define-color red ${config.theme.set.red};
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
      modules-left = [
        "sway/workspaces"
        "tray"
        "custom/pomo"
        "custom/swayidle"
      ];
      modules-center = [ "sway/mode" ];
      modules-right = [
        "custom/rebuild"
        "network#1"
        "network#2"
        "cpu"
        "backlight"
        "custom/wlsunset"
        "wireplumber"
        "bluetooth"
        "battery"
        "clock"
      ];
      "custom/pomo" = {
        format = "{} 󱎫";
        exec = "${pkgs.pomo}/bin/pomo clock";
        interval = 1;
        on-click = "${pkgs.pomo}/bin/pomo pause";
        on-click-right = "${pkgs.pomo}/bin/pomo stop";
      };
      "custom/rebuild" = {
        format = "{}";
        max-length = 25;
        interval = 2;
        exec = "if test -f \"$HOME/tmp/rebuild/status\"; then echo \"$(< $HOME/tmp/rebuild/status)\"; else echo ; fi";
        on-click = viewRebuildLogCmd;
      };
      "custom/swayidle" = {
        format = "{}";
        max-length = 2;
        interval = 2;
        # 󱥑 󱥐 octahedron
        # 󰦞 󰦝 shield
        # 󱓣 󰜗 snowflake
        exec = "if test -f \"$HOME/.local/share/idle-sleep-block\"; then echo '󱓣'; else echo '󰜗'; fi";
        on-click = let app = pkgs.writeShellApplication {
          name = "toggle-idle-sleep-lock";
          runtimeInputs = [ pkgs.coreutils ];
          text = ''
            BLOCKFILE="$HOME/.local/share/idle-sleep-block"
            if test -f "$BLOCKFILE"; then
              rm "$BLOCKFILE"
            else
              touch "$BLOCKFILE"
            fi
          '';
        }; in "${app}/bin/toggle-idle-sleep-lock";
      };
      "custom/wlsunset" = {
        exec = "if ${pkgs.systemd}/bin/systemctl --user --quiet is-active wlsunset.service; then echo ''; else echo ''; fi";
        interval = 2;
        on-click = "${pkgs.toggle-service}/bin/toggle-service wlsunset";
        # This doesn't actually work because the only way to have dynamic tooltips is to use json mode
        # tooltip-format = "${pkgs.writers.writeFish "wlsunset-temp" ''
        #   journalctl --user -ex --unit wlsunset.service | tail | string match --regex "\d{4} K" | tail -1
        # ''}";
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
        on-click = "${pkgs.foot}/bin/foot --app-id=system_monitor ${pkgs.btop}/bin/btop";
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
        format-wifi = "";
        tooltip-format = "{essid} {frequency}GHz {signalStrength}%";
        on-click = "${pkgs.foot}/bin/foot --app-id=nmtui ${pkgs.networkmanager}/bin/nmtui";
      };
      "network#2" = {
        max-length = 60;
        interface = "pvpn*";
        format = "";
        tooltip-format = "{essid}";
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
        format = "{:%I:%M %p} 󱛡";
        format-alt = "{:%a %b %d} 󱛡";
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
